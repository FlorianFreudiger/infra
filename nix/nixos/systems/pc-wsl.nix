{ inputs, self, ... }:
{
  flake.nixosConfigurations.pc-wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Import specific role
      self.nixosModules.wsl

      # Host specific configuration
      (
        { config, ... }:
        {
          networking.hostName = "pc-wsl";

          # Kopia credentials
          age.secrets.kopia-password-pc-wsl = {
            rekeyFile = self + "/secrets/master/kopia-password-pc-wsl.age";
          };
          services.kopia.backups.daily.passwordFile = config.age.secrets.kopia-password-pc-wsl.path;

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
