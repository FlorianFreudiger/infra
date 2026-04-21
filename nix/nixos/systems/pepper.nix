{ inputs, self, ... }:
{
  flake.nixosConfigurations.pepper = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Import specific nixos profile
      self.nixosModules.desktop

      # Host facts
      (
        { ... }:
        {
          infra.hostFacts.memoryGiB = 16;
        }
      )

      # Host specific configuration
      (
        { ... }:
        {
          system.stateVersion = "25.11";
          networking.hostName = "pepper";

          # Add Home Manager configuration for user
          home-manager.users.turtle = {
            home.stateVersion = "25.11";

            imports = [
              # Import specific home-manager profile
              self.homeModules.desktop
            ];

            home.username = "turtle";
            home.homeDirectory = "/home/turtle";
          };

          # Kopia credentials
          age.secrets.kopia-password-pepper = {
            rekeyFile = self + "/secrets/master/kopia-password-pepper.age";
          };

          # Configure network connections interactively with nmcli or nmtui.
          networking.networkmanager.enable = true;
        }
      )

      # Host specific hardware-configuration
      (
        {
          config,
          lib,
          modulesPath,
          ...
        }:
        {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
          ];

          boot.initrd.availableKernelModules = [
            "xhci_pci"
            "ahci"
            "nvme"
            "uas"
            "sd_mod"
          ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" ];
          boot.extraModulePackages = [ ];

          boot.initrd.luks.devices."cryptroot" = {
            device = "/dev/disk/by-uuid/ccd7feb5-2151-4d81-a076-8bd4250ea5d9";
            # Enable automatic unlock
            crypttabExtraOpts = [
              "tpm2-device=auto"
              "tpm2-measure-pcr=yes"
            ];
          };

          fileSystems."/boot" = {
            device = "/dev/disk/by-uuid/5372-6FEF";
            fsType = "vfat";
            options = [
              "umask=0077"
              "fmask=0077"
              "dmask=0077"
            ];
          };

          fileSystems."/" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [ "subvol=@root" ];
          };

          fileSystems."/home" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [ "subvol=@home" ];
          };

          fileSystems."/nix" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [ "subvol=@nix" ];
          };

          swapDevices = [ ];

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

          ## GPU configuration ##
          nixpkgs.config.allowUnfree = true;
          hardware.graphics.enable = true;
          hardware.nvidia = {
            # Last supported version for Pascal GPU generation
            package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

            # Power management through systemd
            powerManagement.enable = false; # TODO: Test sometime

            # Options NOT supported for Pascal GPU generation
            open = false;
            powerManagement.finegrained = false;

            # Hybrid graphics
            prime = {
              sync.enable = true;

              intelBusId = "PCI:0:2:0";
              nvidiaBusId = "PCI:2:0:0";
            };
          };
        }
      )
    ];
  };
}
