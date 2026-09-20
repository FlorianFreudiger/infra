{ ... }:
{
  flake.nixosModules.maintenance =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
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
        # Keep /etc/nixos flake ref. Using path:/... fails when /etc/nixos is a symlink.
        flake = "/etc/nixos#${config.networking.hostName}";
        flags = [
          "--update-input"
          "nixpkgs"
          "--update-input"
          "nixpkgs-unstable"
        ]
        ++ lib.optionals (options ? home-manager) [
          "--update-input"
          "home-manager"
          "--update-input"
          "zen-browser"
        ];
        dates = "03:00";
        randomizedDelaySec = "15min";
        allowReboot = false;
      };

      systemd.services.nixos-upgrade.serviceConfig = {
        # Lower priorities
        # Note this does not affect builds as they run in nix-daemon
        Nice = 19;
        IOSchedulingClass = "idle";
        IOWeight = 20; # default is 100, lower is less priority
      };
    };
}
