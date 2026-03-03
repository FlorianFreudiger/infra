{ ... }:
{
  flake.nixosModules.performance =
    { ... }:
    {
      # Enable zram, note it is only available in WSL via custom kernel
      zramSwap = {
        enable = true;
        algorithm = "zstd";
      };
    };
}
