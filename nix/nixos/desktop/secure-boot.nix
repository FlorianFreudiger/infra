# Configuration for
# Lanzaboote: Secure Boot for NixOS
# + TPM2 support
# + Script to enroll luks keys into the TPM

{ inputs, ... }:
{
  flake.nixosModules.secure-boot =
    { pkgs, lib, ... }:
    {
      ## Lanzaboote: Secure Boot for NixOS ##
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ];

      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";

        autoGenerateKeys.enable = true;
        autoEnrollKeys.enable = true;
      };

      ## TPM2 support ##
      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.tpm2.enable = true;

      security.tpm2 = {
        enable = true;
        pkcs11.enable = true;
        tctiEnvironment.enable = true;
      };

      environment.systemPackages = with pkgs; [
        sbctl

        ## Helper enrollment script ##
        (writeShellApplication {
          name = "cryptenroll-tpm";
          text = ''
            # Allow overriding default PCR bindings
            PCRS="''${PCRS:-0+2+7+15:sha256=0000000000000000000000000000000000000000000000000000000000000000}"

            mapper_dev="$(findmnt -n -o SOURCE /)"
            mapper_dev="''${mapper_dev%%[*}"
            if [ -z "$mapper_dev" ]; then
              echo "Could not determine root mapper device" >&2
              exit 1
            fi

            luks_dev="$(cryptsetup status "$mapper_dev" 2>/dev/null | sed -n 's/^[[:space:]]*device:[[:space:]]*//p' | head -n1)"
            if [ -z "$luks_dev" ]; then
              echo "Could not determine backing LUKS device from $mapper_dev" >&2
              exit 1
            fi

            if ! cryptsetup isLuks "$luks_dev" >/dev/null 2>&1; then
              echo "$luks_dev is not a LUKS device" >&2
              exit 1
            fi

            echo "Mapper device: $mapper_dev"
            echo "LUKS device:   $luks_dev"
            echo "PCRs:          $PCRS"

            echo
            echo "Current keyslots of $luks_dev:"
            systemd-cryptenroll "$luks_dev"

            echo
            read -r -s -p "Press Enter to (re-)enroll TPM, or Ctrl-C to abort."

            echo "Enrolling TPM for $luks_dev"
            systemd-cryptenroll "$luks_dev" --wipe-slot=tpm2
            systemd-cryptenroll "$luks_dev" --tpm2-device=auto --tpm2-pcrs="$PCRS"

            echo
            echo "New keyslots of $luks_dev:"
            systemd-cryptenroll "$luks_dev"
          '';
        })
      ];
    };
}
