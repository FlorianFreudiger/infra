{ inputs, self, ... }:
{
  flake.nixosModules.backup =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Set static kopiaignore definitions here
      kopiaignoreDefinitions = [
        {
          directory = "/home";
          content = ''
            # Global directories and files
            .cache
            .gradle
            .mypy_cache
            .venv
            __pycache__
            node_modules
            *.tmp
            *.bak
            [Dd]esktop.ini

            Code Cache
            CacheStorage
            GPU*Cache
            *Dawn*Cache
            *ShaderCache

            # Home directories
            **/PrismLauncher/assets
            **/PrismLauncher/cache
            **/PrismLauncher/java
            **/PrismLauncher/libraries
            **/PrismLauncher/meta
            */.config/*/Cache
            */.config/Code/Cached*
            */.config/Code/logs
            */.config/heroic/images-cache
            */.config/heroic/store_cache
            */.config/heroic/tools
            */.config/syncthing/index-*
            */.config/zen/*/storage/default/*/cache
            */.jdks
            */.konan
            */.m2
            */.npm
            */.vscode/extensions
            */.vscode-server
            */.vscode-remote-containers
            */.local/lib
            */.local/share/baloo
            */.local/share/flatpak
            */.local/share/JetBrains/Toolbox/apps
            */.local/share/Steam/*
            !*/.local/share/Steam/config
            !*/.local/share/Steam/steamapps
            !*/.local/share/Steam/userdata
            */.local/share/Steam/config/htmlcache
            */.local/share/Steam/steamapps/common
            */.local/share/Steam/steamapps/downloading
            */.local/share/Steam/steamapps/shadercache
            */.local/share/Steam/steamapps/temp
            */.local/share/Steam/steamapps/workshop
            */.local/share/Trash
            */.local/share/umu
            */.local/share/uv/python
            */.local/share/uv/tools
            */.local/state/Heroic/logs
            */.local/state/syncthing/index-*
            */.var/app/*/cache
            */Games/Heroic/*
            !*/Games/Heroic/Prefixes
            */go
            */snap
          '';
        }
        {
          directory = "/srv";
          content = ''
            .cache
          '';
        }
      ];

      # Convert kopiaignore definitions to items in nix store that can be used in activation scripts
      kopiaignoreFiles = lib.imap0 (index: definition: {
        directory = definition.directory;
        target = "${definition.directory}/.kopiaignore";
        source = pkgs.writeText "kopiaignore-${toString index}" definition.content;
      }) kopiaignoreDefinitions;

      kopiaButConnectToServerInsteadOfWebdav = pkgs.writeShellApplication {
        name = "kopia";
        runtimeInputs = [ pkgs.kopia ];
        text = ''
          #!/bin/sh

          # Connect to kopia server instead of webdav
          if [ "$#" -ge 3 ] && [ "$1" = "repository" ] && [ "$2" = "connect" ] && [ "$3" = "webdav" ]; then
            echo "[wrapper] Caught \"kopia repository connect webdav ...\", connecting to server instead."
            shift 3

            KOPIA_SERVER_FINGERPRINT_FILE="${config.age.secrets.kopia-server-cert-fingerprint.path}"
            if [ ! -r "$KOPIA_SERVER_FINGERPRINT_FILE" ]; then
              echo "[wrapper] Missing or unreadable fingerprint file: $KOPIA_SERVER_FINGERPRINT_FILE" >&2
              exit 1
            fi

            KOPIA_SERVER_FINGERPRINT="$(cat "$KOPIA_SERVER_FINGERPRINT_FILE")"
            exec kopia repository connect server --server-cert-fingerprint "$KOPIA_SERVER_FINGERPRINT" "$@"
          elif [ "$#" -ge 3 ] && [ "$1" = "repository" ] && [ "$2" = "create" ] && [ "$3" = "webdav" ]; then
            # The module only creates a repository after connecting failed, so fail to let the unit be retried
            echo "[wrapper] Caught \"kopia repository create webdav ...\", not needed for kopia-servers."
            echo "[wrapper] Failing since this only happens when connecting to the server failed." >&2
            exit 1
          else
            exec kopia "$@"
          fi
        '';
      };

      automaticBackupEnabled = lib.hasAttrByPath [
        "age"
        "secrets"
        "kopia-password-${config.networking.hostName}"
      ] config;
    in
    {
      imports = map (file: "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia/${file}") [
        "default.nix"
        "policy-service.nix"
        "repository-service.nix"
        "snapshot-service.nix"
        "web-service.nix"
      ];

      services.kopia = {
        package = kopiaButConnectToServerInsteadOfWebdav;

        backups.automatic = lib.mkIf automaticBackupEnabled {
          repository.webdav = {
            urlFile = config.age.secrets.kopia-url.path;
          };

          passwordFile = lib.mkDefault config.age.secrets."kopia-password-${config.networking.hostName}".path;

          snapshots =
            let
              mkTimer = onCalendar: {
                enable = true;
                options = {
                  OnCalendar = onCalendar;
                  RandomizedDelaySec = "10min"; # Spread load on kopia server from different hosts
                  FixedRandomDelay = true;
                  Persistent = true;
                };
              };
            in
            {
              home = {
                path = "/home";
                timer = mkTimer "*-*-* 02/4:45:00"; # Run every 4 hours: 02:45, 06:45, ..., 22:45
              };
              srv = {
                path = "/srv";
                timer = mkTimer "*-*-* *:15:00"; # Run every hour: 00:15, 01:15, ..., 23:15
              };
            };
        };
      };

      warnings = lib.optional (
        !automaticBackupEnabled
      ) "Automatic Kopia backup is disabled because no host-specific Kopia password is configured!";

      age.secrets.kopia-url = {
        rekeyFile = self + "/secrets/master/kopia-url.age";
      };
      age.secrets.kopia-server-cert-fingerprint = {
        rekeyFile = self + "/secrets/master/kopia-server-cert-fingerprint.age";
      };

      system.activationScripts.kopiaignoreSymlinks.text = ''
        ${lib.concatMapStringsSep "\n" (entry: ''
          if [ -d ${lib.escapeShellArg entry.directory} ]; then
            ln -sfn ${entry.source} ${lib.escapeShellArg entry.target}
          fi
        '') kopiaignoreFiles}
      '';

      # Add wrapper script to run kopia with the right repository config
      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "kopia-automatic";
          runtimeInputs = [ kopiaButConnectToServerInsteadOfWebdav ];
          text = ''
            #!/bin/sh
            export KOPIA_CONFIG_PATH=/var/lib/kopia/automatic/repository.config
            exec kopia "$@"
          '';
        })
      ];
    };
}
