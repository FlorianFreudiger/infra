{ self, ... }:
{
  flake.nixosModules.network =
    { config, ... }:
    {
      services.tailscale = {
        enable = true;
        extraUpFlags = [
          "--accept-routes"
          "--advertise-tags=tag:test"
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
    };
}
