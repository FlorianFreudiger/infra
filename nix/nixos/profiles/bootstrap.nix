# Base configuration to initialize a NixOS system with before applying the full configuration

{ self, ... }:
{
  flake.nixosModules.bootstrap =
    { ... }:
    {
      imports = [
        self.nixosModules.essential

        # Add users with their authorized SSH keys
        self.nixosModules.users

        # Setup SSH to allow remote access on headless devices
        self.nixosModules.ssh

        # Add performance module to enable things like zram which might be necessary for builds on low-memory devices
        self.nixosModules.performance
      ];

      # Set low-end hostFacts to ensure bootstrapping works on all devices, can be overridden afterwards
      infra.hostFacts.memoryGiB = 1;
    };
}
