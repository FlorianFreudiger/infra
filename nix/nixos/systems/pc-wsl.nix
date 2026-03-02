{ inputs, self, ... }:
{
  flake.nixosConfigurations.pc-wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Import specific role
      self.nixosModules.wsl

      # Host specific configuration
      (
        { ... }:
        {
          networking.hostName = "pc-wsl";

          home-manager.users.turtle = {
            imports = [
              self.homeModules.default
              self.homeModules.dev-all
            ];

            home.username = "turtle";
            home.homeDirectory = "/home/turtle";

            home.stateVersion = "25.11";
          };
          system.stateVersion = "25.11";
        }
      )
    ];
  };
}
