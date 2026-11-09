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
        keepassxc
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

      services.tailscale-systray = {
        enable = true;
        theme = "light:nobg";
      };

      programs.zed-editor = {
        enable = true;

        # Language home-modules will add the extensions themselves
        extensions = [
          "git-firefly"
        ];

        userSettings = {
          # General
          auto_update = false;
          telemetry = {
            metrics = false;
            anthropic_retention = false;
          };
        };
      };
    };
}
