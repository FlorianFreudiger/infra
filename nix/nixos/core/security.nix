{ ... }:
{
  flake.nixosModules.security =
    { ... }:
    {
      # Ensure firewall is enabled
      networking.firewall.enable = true;
    };
}
