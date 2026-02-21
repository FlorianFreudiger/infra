{ inputs, self, ... }:
{
  flake.nixosModules.wsl =
    { ... }:
    {
      imports = [
        self.nixosModules.essential
        inputs.nixos-wsl.nixosModules.wsl
      ];

      wsl.enable = true;
      wsl.defaultUser = "nixos";
    };
}
