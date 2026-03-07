{ ... }:
{
  flake.nixosModules.performance =
    { lib, config, ... }:
    {
      options.infra.hostFacts = {
        memoryGiB = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Host memory size used for performance tuning.";
        };
      };

      config =
        let
          mem = config.infra.hostFacts.memoryGiB;
          lowMem = builtins.isInt mem && mem <= 4; # Consider low memory if 4 GiB or less
        in
        {
          # Enable zram, note it is only available in WSL via custom kernel
          zramSwap = {
            enable = true;
            algorithm = "zstd";
          }
          # Increase memory percent for hosts with low memory
          // lib.optionalAttrs lowMem {
            memoryPercent = 100; # max memory that can be stored in zram
          };

          # Limit number of jobs and concurrent tasks for low-memory hosts to avoid OOM
          nix.settings = lib.mkIf lowMem {
            max-jobs = 1;
            cores = 1;
          };
        };
    };
}
