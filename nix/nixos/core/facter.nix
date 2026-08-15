{ self, ... }:
{
  flake.nixosModules.facter =
    { config, lib, ... }:
    let
      reportPath = self + "/secrets/hosts/${config.networking.hostName}/facter.json";
    in
    {
      hardware.facter =
        { }
        // lib.optionalAttrs (builtins.pathExists reportPath) {
          reportPath = reportPath;
        };

      warnings = lib.optional (
        !builtins.pathExists reportPath
      ) "Facter report file not found at ${reportPath}, skipping facter.";

      # Extract information from facter report if available
      infra.hostFacts =
        let
          facter = config.hardware.facter.report;

          memoryMiB =
            let
              memoryEntries = facter.hardware.memory or [ ];
              allResources = lib.concatMap (m: m.resources or [ ]) memoryEntries;
              physMem = lib.filter (r: r.type or "" == "phys_mem") allResources;
            in
            if physMem == [ ] then null else (lib.head physMem).range / 1024 / 1024;
        in
        lib.optionalAttrs (memoryMiB != null) {
          memoryMiB = memoryMiB;
        };
    };
}
