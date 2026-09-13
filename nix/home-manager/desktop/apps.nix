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
        jetbrains-toolbox
        signal-desktop
        vscode
      ];

      programs.discord = {
        enable = true;
        settings.SKIP_HOST_UPDATE = true;
      };

      programs.ghostty.enable = true;

      services.syncthing.enable = true;
      services.syncthing.tray.enable = true;
    };
}
