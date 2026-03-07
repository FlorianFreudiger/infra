{ inputs, ... }:
{
  flake.nixosModules.maintenance =
    { ... }:
    {
      # Automatic garbage collection of old generations and store paths
      nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 30d";
      };

      # Automatic updates
      system.autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        dates = "03:00";
        randomizedDelaySec = "15min";
        allowReboot = false;
      };
    };
}
