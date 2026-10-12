# Try to increase power efficiency by:
# - PowerTOP: Apply some recommended power-saving tweaks

{ ... }:
{
  flake.nixosModules.power-efficiency =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        pciutils # For lspci to check PCIe devices and their ASPM support
        powertop # Make PowerTOP available on command line for interactive use
        nvme-cli
      ];

      ## PowerTOP ##
      powerManagement.powertop.enable = true;
    };
}
