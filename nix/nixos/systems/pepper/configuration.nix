{ inputs, self, ... }:
{
  flake.nixosConfigurations.pepper = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Import specific nixos profile
      self.nixosModules.desktop

      # Host specific configuration
      (
        { pkgs, ... }:
        {
          system.stateVersion = "25.11";
          networking.hostName = "pepper";

          infra.hostFacts.rootDrive = {
            isSSD = true;
            supportsTrim = true;
          };

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
          networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
        }
      )

      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Host specific additions to the generated hardware-configuration
      (
        { config, ... }:
        {
          # Disable dead webcam, otherwise causes log spam and possibly interferes with system suspend/resume
          systemd.tmpfiles.rules = [ "w /sys/bus/usb/devices/usb1/1-0:1.0/usb1-port3/disable - - - - 1" ];
          powerManagement.powerDownCommands = "echo 1 > /sys/bus/usb/devices/usb1/1-0:1.0/usb1-port3/disable || true";

          # Enable HP mute LED
          boot.extraModprobeConfig = "options snd-hda-intel model=hp-mute-led-mic3";

          # Additional mount options for the generated filesystems
          fileSystems."/boot".options = [ "umask=0077" ];
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
            # Last supported version for Pascal GPU generation
            package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

            # Power management through systemd
            powerManagement.enable = true;

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
