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
        daemon.settings = {
          # Keep containers running when the daemon is restarted, e.g. for updates
          live-restore = true;

          # Enable nftables support if used
          firewall-backend = lib.mkIf config.networking.nftables.enable "nftables";
        };
        extraPackages = lib.mkIf config.networking.nftables.enable [ pkgs.nftables ];
      };

      # Extra packages for container management
      environment.systemPackages = with pkgs; [
        lazydocker
      ];
    };
}
