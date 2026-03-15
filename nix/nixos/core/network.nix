{ self, ... }:
{
  flake.nixosModules.network =
    { config, lib, ... }:
    {
      # Use nftables instead of iptables
      networking.nftables.enable = true;

      services.tailscale = {
        enable = true;
        extraUpFlags = [
          "--accept-routes"
          "--advertise-tags=tag:test"
          # Set hostname manually since Tailscale might be applied before specified hostname
          ("--hostname=" + config.networking.hostName)
        ];
        extraSetFlags = [
          "--accept-routes"
        ];
        extraDaemonFlags = [ "--no-logs-no-support" ]; # Disable telemetry

        # Configure network settings to allow direct connections and routing features
        openFirewall = true;
        useRoutingFeatures = "both";

        authKeyFile = config.age.secrets.tailscale-authkey.path;
        authKeyParameters.ephemeral = false;
      };

      age.secrets.tailscale-authkey = {
        rekeyFile = self + "/secrets/master/tailscale-authkey.age";
      };

      # Use nftables if enabled
      systemd.services.tailscaled.serviceConfig.Environment = lib.mkIf config.networking.nftables.enable [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];

      # Increase UDP buffer sizes for QUIC
      # See https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
      boot.kernel.sysctl = {
        "net.core.rmem_max" = 16777216; # 16 MiB
        "net.core.wmem_max" = 16777216; # 16 MiB
      };
    };
}
