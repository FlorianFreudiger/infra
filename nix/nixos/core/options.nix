{ ... }:
{
  flake.nixosModules.options =
    { lib, ... }:
    {
      options.infra.hostFacts = {
        memoryMiB = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Host memory capacity";
        };
      };
    };
}
