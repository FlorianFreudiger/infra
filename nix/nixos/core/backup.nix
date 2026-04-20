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
            *.tmp
            *.bak
            [Dd]esktop.ini

            # Home directories
            */.gradle
            */.konan
            */.m2
            */.npm
            */.vscode-server
            */.vscode-remote-containers
            */.local/lib
            */.local/share/Trash
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
            echo "[wrapper] Caught \"kopia repository create webdav ...\", not needed for kopia-servers."
          else
            exec kopia "$@"
          fi
        '';
      };

      dailyBackupEnabled = lib.hasAttrByPath [
        "age"
        "secrets"
        "kopia-password-${config.networking.hostName}"
      ] config;
    in
    {
      imports = [
        "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia"
      ];

      services.kopia = {
        package = kopiaButConnectToServerInsteadOfWebdav;

        backups.daily = lib.mkIf dailyBackupEnabled {
          repository.webdav = {
            urlFile = config.age.secrets.kopia-url.path;
          };

          passwordFile = lib.mkDefault config.age.secrets."kopia-password-${config.networking.hostName}".path;

          paths = [
            "/home"
            "/srv"
          ];

          timerConfig = {
            OnCalendar = "*-*-* 04:00:00";
            Persistent = true;
          };
        };
      };

      warnings =
        lib.optional (!dailyBackupEnabled)
          "Automatic Kopia backup is disabled because no host-specific Kopia password is configured!";

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
          name = "kopia-daily";
          runtimeInputs = [ kopiaButConnectToServerInsteadOfWebdav ];
          text = ''
            #!/bin/sh
            export KOPIA_CONFIG_PATH=/var/lib/kopia/daily/repository.config
            exec kopia "$@"
          '';
        })
      ];
    };
}
