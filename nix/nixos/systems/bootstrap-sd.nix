{ inputs, self, ... }:
{
  flake = {
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
