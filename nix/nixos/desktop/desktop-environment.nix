{ inputs, ... }:
{
  flake.nixosModules.desktop-environment =
    { pkgs, ... }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      imports = [
        "${inputs.nixpkgs-unstable}/nixos/modules/services/display-managers/plasma-login-manager.nix"
      ];

      services.desktopManager.plasma6.enable = true;
      services.displayManager.plasma-login-manager = {
        enable = true;
        package = pkgs-unstable.kdePackages.plasma-login-manager;
      };
      programs.xwayland.enable = true;
    };
}
