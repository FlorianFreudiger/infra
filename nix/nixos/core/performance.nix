{ ... }:
{
  flake.nixosModules.performance =
    { lib, config, ... }:
    {
      config =
        let
          memMiB = config.infra.hostFacts.memoryMiB;
          lowMem = builtins.isInt memMiB && memMiB <= 4096; # Consider low memory if 4 GiB or less
        in
        lib.mkMerge [
          {
            # Enable zram, note it is only available in WSL via custom kernel
            zramSwap = {
              enable = true;
              algorithm = "zstd";
            };
          }
          (lib.mkIf lowMem {
            # Increase memory percent for hosts with low memory
            zramSwap.memoryPercent = 120; # max memory that can be stored in zram

            # Limit number of jobs and concurrent tasks for low-memory hosts to avoid OOM
            nix.settings = {
              max-jobs = 1;
              cores = 1;
            };

            # Limit max memory for nixos-upgrade service if used
            systemd.services.nixos-upgrade.serviceConfig = lib.mkIf config.system.autoUpgrade.enable {
              MemoryHigh = "${toString (builtins.floor (memMiB / 2))}M";
              MemoryMax = "${toString (builtins.floor (memMiB * 3 / 4))}M";
            };
          })
        ];
    };
}
