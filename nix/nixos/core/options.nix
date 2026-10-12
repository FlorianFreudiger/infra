{ ... }:
{
  flake.nixosModules.options =
    { lib, ... }:
    {
      options.infra = {

        hostFacts = {
          memoryMiB = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Host memory capacity";
          };

          isDesktop = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether the host is a desktop system or headless";
          };

          rootDrive = {
            isSSD = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Whether the drive hosting / is a solid state drive, null if unknown";
            };

            supportsTrim = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Whether the drive hosting / supports TRIM/discard, null if unknown";
            };
          };
        };
      };
    };
}
