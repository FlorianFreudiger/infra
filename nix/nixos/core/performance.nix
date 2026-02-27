{ ... }:
{
  flake.nixosModules.performance =
    { ... }:
    {
      # Enable zram, note it is not available in WSL
      zramSwap = {
        enable = true;
      };
    };
}
