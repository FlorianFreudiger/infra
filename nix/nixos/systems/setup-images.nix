{ inputs, self, ... }:
{
  flake = {
    ### Installation CD images for new hosts, to setup on host storage. ###

    nixConfigurations.installation-cd-minimal-x64 = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        self.nixosModules.bootstrap
      ];
    };

    images.installation-cd-minimal-x64 =
      self.nixConfigurations.installation-cd-minimal-x64.config.system.build.isoImage;

    nixConfigurations.installation-cd-graphical-x64 = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
        self.nixosModules.bootstrap
      ];
    };

    images.installation-cd-graphical-x64 =
      self.nixConfigurations.installation-cd-graphical-x64.config.system.build.isoImage;

    ### Bootstrap SD image for something like a Raspberry Pi, image media will be the device storage. ###

    nixosModules.bootstrap-sd =
      { pkgs, ... }:
      {
        image.baseName = "nixos-bootstrap-sd-${pkgs.stdenv.hostPlatform.system}";
      };

    # Build on native aarch64 linux host or via binary emulation, can use nix cache
    nixosConfigurations.bootstrap-sd-aarch64 = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        self.nixosModules.bootstrap
        self.nixosModules.bootstrap-sd
      ];
    };

    images.bootstrap-sd-aarch64 =
      self.nixosConfigurations.bootstrap-sd-aarch64.config.system.build.sdImage;

    # Note this seems to cross-compile EVERYTHING for the target platform which is very slow
    nixosConfigurations.bootstrap-sd-aarch64-from-x64 = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        self.nixosModules.bootstrap
        self.nixosModules.bootstrap-sd
        (
          { ... }:
          {
            nixpkgs.buildPlatform = "x86_64-linux";
            nixpkgs.hostPlatform = "aarch64-linux";
          }
        )
      ];
    };

    images.bootstrap-sd-aarch64-from-x64 =
      self.nixosConfigurations.bootstrap-sd-aarch64-from-x64.config.system.build.sdImage;
  };
}
