{ inputs, self, ... }:
{
  flake.nixosConfigurations.pc-wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Host specific configuration
      (
        { ... }:
        {
          imports = [
            self.nixosModules.wsl
          ];

          system.stateVersion = "25.11";
        }
      )
    ];
  };
}
