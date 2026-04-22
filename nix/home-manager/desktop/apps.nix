{ ... }:
{
  flake.homeModules.desktop-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        keepassxc
        jetbrains-toolbox
        vscode
        python313Packages.gurobipy
      ];

      services.syncthing.enable = true;
      services.syncthing.tray.enable = true;
    };
}
