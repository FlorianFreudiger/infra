{ inputs, self, ... }:
{
  flake.nixosConfigurations.broccoli = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Import specific nixos profile
      self.nixosModules.desktop

      # Host specific configuration
      (
        { pkgs, ... }:
        {
          system.stateVersion = "26.05";
          networking.hostName = "broccoli";

          infra.hostFacts.rootDrive = {
            isSSD = true;
            supportsTrim = true;
          };

          # Add Home Manager configuration for user
          home-manager.users.turtle = {
            home.stateVersion = "26.05";

            imports = [
              # Import specific home-manager profile
              self.homeModules.desktop
            ];

            home.username = "turtle";
            home.homeDirectory = "/home/turtle";
          };

          # Kopia credentials
          age.secrets.kopia-password-broccoli = {
            rekeyFile = self + "/secrets/master/kopia-password-broccoli.age";
          };

          # Configure network connections interactively with nmcli or nmtui.
          networking.networkmanager.enable = true;
          networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

          # bootstrap sets no boot loader, and NixOS falls back to GRUB.
          # systemd-boot also registers the "Linux Boot Manager" firmware entry.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
        }
      )

      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Host specific additions to the generated hardware-configuration
      (
        { ... }:
        {
          # Additional mount options for the generated btrfs subvolumes
          fileSystems."/".options = [
            "compress=zstd"
            "noatime"
          ];
          fileSystems."/home".options = [
            "compress=zstd"
            "noatime"
          ];
          fileSystems."/nix".options = [
            "compress=zstd"
            "noatime"
          ];

          ## GPU configuration ##
          nixpkgs.config.allowUnfreePackages = [
            "nvidia-kernel-modules"
            "nvidia-settings"
            "nvidia-x11"
          ];
          hardware.graphics.enable = true;
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.nvidia = {
            open = true;

            # Power management through systemd
            powerManagement.enable = true;
          };
        }
      )
    ];
  };
}
