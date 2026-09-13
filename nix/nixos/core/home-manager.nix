# General home-manager configuration shared by all hosts using HM

{ inputs, ... }:
{
  flake.nixosModules.home-manager =
    { ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        # Use separate nixpkgs for home-manager to be able to control the unfree packages allowlist separately
        useGlobalPkgs = false;

        useUserPackages = true;
      };
    };
}
