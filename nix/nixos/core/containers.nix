{ ... }:
{
  flake.nixosModules.containers =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      virtualisation.docker = {
        enable = true;
        # Use Docker 29 until general "docker" package is updated to 29+
        # Since it enables nftables support via daemon settings
        package = pkgs.docker_29;

        daemon.settings = {
          # Keep containers running when the daemon is restarted, e.g. for updates
          live-restore = true;
        };
      }
      # Enable nftables support if used
      // lib.optionalAttrs config.networking.nftables.enable {
        daemon.settings.firewall-backend = "nftables";
        extraPackages = [ pkgs.nftables ];
      };
    };
}
