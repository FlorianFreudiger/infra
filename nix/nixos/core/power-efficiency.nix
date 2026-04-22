# Try to increase power efficiency by:
# - PowerTOP: Apply some recommended power-saving tweaks
# - AutoASPM: Activate PCIe Active State Power Management (ASPM) on supported devices

{ inputs, ... }:
{
  flake.nixosModules.power-efficiency =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        pciutils # For lspci to check PCIe devices and their ASPM support
        powertop # Make PowerTOP available on command line for interactive use
      ];

      ## PowerTOP ##
      powerManagement.powertop.enable = true;

      ## AutoASPM ##
      imports = [
        inputs.autoaspm.nixosModules.default
      ];
      services.autoaspm.enable = true;
    };
}
