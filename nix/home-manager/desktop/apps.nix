{ ... }:
{
  flake.homeModules.desktop-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        keepassxc
        jetbrains-toolbox
        syncthing
        syncthingtray
        vscode
        python313Packages.gurobipy
      ];
    };
}
