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

      # Host specific hardware-configuration
      (
        {
          config,
          lib,
          modulesPath,
          ...
        }:
        {
          services.autoaspm.enable = lib.mkForce false;

          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
          ];

          boot.initrd.availableKernelModules = [
            "vmd"
            "xhci_pci"
            "ahci"
            "nvme"
            "usbhid"
            "usb_storage"
            "sd_mod"
          ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" ];
          boot.extraModulePackages = [ ];

          fileSystems."/" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [
              "subvol=@root"
              "compress=zstd"
              "noatime"
            ];
          };

          boot.initrd.luks.devices."cryptroot".device =
            "/dev/disk/by-uuid/f6728a29-c471-4669-9d6f-4f49a6e8917c";

          fileSystems."/home" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [
              "subvol=@home"
              "compress=zstd"
              "noatime"
            ];
          };

          fileSystems."/nix" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [
              "subvol=@nix"
              "compress=zstd"
              "noatime"
            ];
          };

          fileSystems."/boot" = {
            device = "/dev/disk/by-uuid/4FD9-8151";
            fsType = "vfat";
            options = [
              "fmask=0077"
              "dmask=0077"
            ];
          };

          swapDevices = [ ];

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
