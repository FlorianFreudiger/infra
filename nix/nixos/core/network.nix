{ self, ... }:
{
  flake.nixosModules.network =
    { config, ... }:
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
        useRoutingFeatures = "both";
        authKeyFile = config.age.secrets.tailscale-authkey.path;
        authKeyParameters.ephemeral = false;
      };

      age.secrets.tailscale-authkey = {
        rekeyFile = self + "/secrets/master/tailscale-authkey.age";
      };

      # Increase UDP buffer sizes for QUIC
      # See https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
      boot.kernel.sysctl = {
        "net.core.rmem_max" = 16777216; # 16 MiB
        "net.core.wmem_max" = 16777216; # 16 MiB
      };
    };
}
