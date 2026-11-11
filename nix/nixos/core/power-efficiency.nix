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
      powerManagement.powertop = {
        enable = true;

        # Disable auto-suspend on input usb devices, as that can cause inputs to be delayed or dropped
        # Devices plugged in after boot are not affected
        postStart = ''
          for i in /sys/class/input/input*; do
            d=$(readlink -f "$i")
            while [ "$d" != / ] && [ ! -e "$d/idVendor" ]; do d=$(dirname "$d"); done
            if [ -e "$d/power/control" ]; then echo on > "$d/power/control"; fi
          done
        '';
      };
    };
}
