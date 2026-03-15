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
        ]
        ++ lib.optionals (options ? home-manager) [
          "--update-input"
          "home-manager"
        ];
        dates = "03:00";
        randomizedDelaySec = "15min";
        allowReboot = false;
      };

      systemd.services.nixos-upgrade.serviceConfig = {
        # Fix nixos-upgrade service aborting when repo is owned by different user
        # by bind-mounting a dedicated gitconfig with safe.directory=*
        BindReadOnlyPaths = [
          "${pkgs.writeText "nixos-upgrade-gitconfig" ''
            [safe]
              directory = *
          ''}:/etc/gitconfig"
        ];

        # Lower priorities
        # Note this does not affect builds as they run in nix-daemon
        Nice = 19;
        IOSchedulingClass = "idle";
        IOWeight = 20; # default is 100, lower is less priority
      };
    };
}
