# Base configuration to initialize a NixOS system with before applying the full configuration

{ self, ... }:
{
  flake.nixosModules.bootstrap =
    { ... }:
    {
      imports = [
        self.nixosModules.users

        # Setup SSH to allow remote access on headless devices
        self.nixosModules.ssh
      ];

      # Configuration to enable applying the full configuration via nh
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      programs.nh.enable = true;
    };
}
