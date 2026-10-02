{ inputs, ... }:
{
  flake.homeModules.dev-ai =
    { pkgs, lib, ... }:
    let
      deny-credential-files = [
        # Tokens
        "~/.cargo/credentials.toml"
        "~/.claude.json"
        "~/.claude/.credentials.json"
        "~/.docker/config.json"
        "~/.git-credentials"
        "~/.netrc"
        "~/.npmrc"
        "~/.pypirc"

        # Shell history
        "~/.bash_history"
        "~/.local/share/fish/fish_history"
      ];
      block-dirs = [
        # Keys and identities
        "/run/agenix.d"
        "~/.gnupg"
        "~/.ssh"
        "~/.config/age"
        "~/.config/syncthing"
        "~/.local/state/syncthing"
        "~/.password-store"

        # CLI tokens
        "~/.aws"
        "~/.azure"
        "~/.config/gcloud"
        "~/.config/gh"
        "~/.copilot"
        "~/.kube"

        # Desktop secret stores
        "~/.config/kdeconnect"
        "~/.local/share/keyrings"
        "~/.local/share/kwalletd"

        # Browser and app sessions
        "~/.config/chromium"
        "~/.config/discord"
        "~/.mozilla"
        "~/.zen"
      ];
      read-only-dirs = [
        "/etc/nixos"
      ];

      # Absolute paths require double leading slashes in claude's permissions rules
      claude-rule-path = p: if lib.hasPrefix "/" p then "/" + p else p;
      claude-rule-dir = tool: p: "${tool}(${claude-rule-path p}/**)";
      claude-rule-file = tool: p: "${tool}(${claude-rule-path p})";

      claude-settings = (pkgs.formats.json { }).generate "claude-settings.json" {
        ### Security ###
        # Add some more rules to auto-mode
        autoMode = {
          classifyAllShell = true;
          soft_deny = [
            "$defaults"

            # Try to avoid attacks through things like python module shadowing
            # See https://embracethered.com/blog/posts/2026/breaking-claude-code-opus-5-and-automode/
            "Never change the working directory to one which contents you do not trust."
            "Never spawn a process with the working directory set to one which contents you do not trust."
          ];
          hard_deny = [
            "$defaults"
            "Never switch, add to boot, or apply a NixOS configuration."
            "Never run \"wsl.exe\", directly or through another program."

            # Try to avoid sandbox escapes through excluded commands
            "Never chain shell commands after a \"nix\" command."
            "Never use the \"nix\" command to run another unrelated command."
            "Never use unsafe options of the \"nix\" command, such as \"allow-unsafe-native-code-during-evaluation\"."
            "Never pass \"--impure\", \"--expr\", \"--file\", \"-f\" or \"--option\" to a \"nix\" command."
            "Never add flake inputs, \"builtins.path\" or \"builtins.fetchTree\" references that point at local paths outside the repository."
          ];
        };

        # Require approval before claude can send a message to sessions of different machines
        isolatePeerMachines = true;

        # Restrict claude some more
        permissions = {
          disableBypassPermissionsMode = "disable";
          deny =
            map (claude-rule-file "Read") deny-credential-files
            ++ map (claude-rule-file "Edit") deny-credential-files
            ++ map (claude-rule-dir "Read") block-dirs
            ++ map (claude-rule-dir "Edit") block-dirs
            ++ map (claude-rule-dir "Edit") read-only-dirs
            ++ [
              "Bash(*nixos-rebuild*)"
              "Bash(*nh os*)"
              "Bash(*nh home*)"
              "Bash(*wsl.exe*)"
              "Edit(//**/.git/config)"
              "Edit(//**/.git/hooks/**)"
            ];
        };

        # Configure built-in sandbox
        sandbox = {
          # Force enable sandbox
          enabled = true;
          failIfUnavailable = true;
          allowUnsandboxedCommands = false;

          # Restrict filesystem
          filesystem = {
            denyRead = block-dirs;
            denyWrite = block-dirs ++ read-only-dirs;
          };
          credentials = {
            files = map (path: {
              path = path;
              mode = "deny";
            }) deny-credential-files;
          };

          excludedCommands = [
            # Nix commands require nix-daemon
            "nix path-info *"
            "nix derivation *"
            "nix why-depends *"
            "nix log *"
            "nix store diff-closures *"
            "nix build *"
            "nix eval *"
            "nix flake check *"
            "nix flake metadata *"
            "nix flake show *"

            # Diagnostics that require dbus or netns
            # No wildcards so they can not be used to chain commands.
            "hostnamectl"
            "ip -br addr"
            "ip route"
            "resolvectl status"
            "systemctl --failed"
            "systemctl --failed --no-pager"
            "systemctl list-timers"
            "systemctl list-timers --no-pager"
            "systemctl list-units"
            "systemctl list-units --no-pager"
            "systemctl list-units --failed"
            "systemctl list-units --failed --no-pager"
            "tailscale status"
            "timedatectl"
          ];
        };

        ### UX ###
        # Keep fast-mode off by default
        fastMode = false;
        fastModePerSessionOptIn = true;

        timeFormat = "24-hour";
        cleanupPeriodDays = 180; # Increase session lifetime from the default of 30 days
      };

      unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfreePackages = [ "claude-code" ];
      };
    in
    {
      programs.claude-code = {
        enable = true;
        # Wrap the claude binary to pass in the settings file
        # instead of writing user settings, since the latter would make the file read-only.
        package = pkgs.symlinkJoin {
          name = "claude-code-wrapped";
          # Pull claude-code from unstable nixpkgs to get more up to date versions
          paths = [ unstable.claude-code ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/claude \
              --add-flags "--settings ${claude-settings}" \
              --set DISABLE_TELEMETRY 1
          '';
        };
      };
    };
}
