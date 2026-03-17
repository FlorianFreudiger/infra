{ inputs, self, ... }:
{
  flake.nixosConfigurations.pc-wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Import specific nixos profile
      self.nixosModules.wsl

      # Host facts
      (
        { ... }:
        {
          infra.hostFacts.memoryGiB = 32;
        }
      )

      # Host specific configuration
      (
        { config, ... }:
        {
          system.stateVersion = "25.11";
          networking.hostName = "pc-wsl";

          # Add Home Manager configuration for user
          home-manager.users.turtle = {
            home.stateVersion = "25.11";

            imports = [
              # Import specific home-manager profile
              self.homeModules.development
            ];

            home.username = "turtle";
            home.homeDirectory = "/home/turtle";
          };

          # Kopia credentials
          age.secrets.kopia-password-pc-wsl = {
            rekeyFile = self + "/secrets/master/kopia-password-pc-wsl.age";
          };
          services.kopia.backups.daily.passwordFile = config.age.secrets.kopia-password-pc-wsl.path;

          # Use system for building aarch64 image via binary emulation
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          wsl.interop.register = true;
        }
      )
    ];
  };
}
