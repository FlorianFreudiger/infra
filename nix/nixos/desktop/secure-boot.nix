# Configuration for
# Lanzaboote: Secure Boot for NixOS
# + TPM2 support

{ inputs, ... }:
{
  flake.nixosModules.secure-boot =
    { pkgs, lib, ... }:
    {
      ## Lanzaboote: Secure Boot for NixOS ##
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ];

      environment.systemPackages = with pkgs; [
        sbctl
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
    };
}
