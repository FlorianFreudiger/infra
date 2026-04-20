{ inputs, self, ... }:
{
  flake.nixosConfigurations.blueberry = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      # Import specific nixos profile
      self.nixosModules.server

      # Host facts
      (
        { ... }:
        {
          infra.hostFacts.memoryGiB = 1;
        }
      )

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

      # Host specific hardware-configuration
      (
        { lib, modulesPath, ... }:
        {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
          ];

          boot.initrd.availableKernelModules = [ ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ ];
          boot.extraModulePackages = [ ];

          fileSystems."/" = {
            device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
            fsType = "ext4";
          };

          swapDevices = [
            {
              device = "/swapfile";
              size = 4 * 1024; # 4 GiB
              priority = -1;
            }
          ];

          nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
        }
      )
    ];
  };
}
