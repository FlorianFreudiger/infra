{ inputs, self, ... }:
{
  flake.nixosConfigurations.blueberry = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      # Import specific nixos profile
      self.nixosModules.server

      # Host specific configuration
      (
        { ... }:
        {
          system.stateVersion = "25.11";
          networking.hostName = "blueberry";

          # Add Home Manager configuration for user
          home-manager.users.turtle = {
            home.stateVersion = "25.11";

            imports = [
              # Import specific home-manager profile
              self.homeModules.server
            ];

            home.username = "turtle";
            home.homeDirectory = "/home/turtle";
          };

          # Kopia credentials
          age.secrets.kopia-password-blueberry = {
            rekeyFile = self + "/secrets/master/kopia-password-blueberry.age";
          };

          # Use extlinux bootloader instead of GRUB
          boot.loader.grub.enable = false;
          boot.loader.generic-extlinux-compatible.enable = true;

          # networking.networkmanager.enable = true;
        }
      )

      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Host specific additions to the generated hardware-configuration
      (
        { ... }:
        {
          swapDevices = [
            {
              device = "/swapfile";
              size = 4 * 1024; # 4 GiB
              priority = -1;
            }
          ];
        }
      )
    ];
  };
}
