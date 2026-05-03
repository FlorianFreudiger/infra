{ ... }:
{
  flake.homeModules.desktop-apps =
    { pkgs, ... }:
    {
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

      services.syncthing.enable = true;
      services.syncthing.tray.enable = true;
    };
}
