{ ... }:
{
  flake.nixosModules.desktop-environment =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      programs.xwayland.enable = true;

      # Desktop applications that are nice to have and not user-specific
      environment.systemPackages = with pkgs; [
        # System Utilities
        kdePackages.discover # Software center for Flatpaks/firmware updates
        kdePackages.ksystemlog # System log viewer
        kdePackages.isoimagewriter # Write hybrid ISOs to USB
        kdePackages.partitionmanager # Disk and partition management
        hardinfo2 # System benchmarks and hardware info
        wayland-utils # Wayland diagnostic tools
        wl-clipboard # Wayland copy/paste support

        # General Applications
        kdePackages.kamoso # Webcam application
        kdePackages.kcalc # Calculator
        kdePackages.kcharselect # Character map
        kdePackages.kclock # Clock app
        kdePackages.kcolorchooser # Color picker
        kdePackages.kolourpaint # Simple paint program
        kdePackages.qrca # QR code scanner and generator
        kdePackages.spectacle # Screenshot tool
        kdiff3 # File/directory comparison tool
        vlc # Media player
      ];
    };
}
