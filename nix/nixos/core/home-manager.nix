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
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
