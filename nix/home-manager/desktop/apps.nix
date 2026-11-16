{ ... }:
{
  flake.homeModules.desktop-apps =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfreePackages = [
        "discord"
        "jetbrains-toolbox"
        "vscode"
      ];

      home.packages = with pkgs; [
        (jetbrains-toolbox.override {
          # Fix download link
          fetchzip = a: fetchzip (a // { url = lib.replaceStrings [ "-cdn" ] [ "" ] a.url; });
        })
        signal-desktop
      ];

      programs.discord = {
        enable = true;
        settings.SKIP_HOST_UPDATE = true;
      };

      programs.ghostty.enable = true;

      services.tailscale-systray.enable = true;

      programs.zed-editor = {
        enable = true;

        # Language home-modules will add their extensions themselves
        extensions = [
          "git-firefly"
          "just"
        ];

        userSettings = {
          # General
          auto_update = false;
          telemetry = {
            diagnostics = false;
            metrics = false;
            anthropic_retention = false;
          };

          # Window & Layout
          title_bar.show_sign_in = false;
        };
      };
    };
}
