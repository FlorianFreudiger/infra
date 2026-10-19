{ ... }:
{
  flake.nixosModules.gaming =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      nixpkgs.config.allowUnfreePackages = [
        "steam"
        "steam-unwrapped"
      ];

      environment.systemPackages = with pkgs; [
        protonup-qt
        steam-run
      ];

      # Enable 32-bit graphics support
      hardware.graphics.enable32Bit = true;

      # Gamemode provides performance optimizations for games
      programs.gamemode.enable = true;
      # Add all normal users to gamemode group
      users.groups.gamemode.members = lib.attrNames (
        lib.filterAttrs (_: user: user.isNormalUser) config.users.users
      );

      programs.steam = {
        enable = true;

        # Enhance Proton
        protontricks.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];

        extraPackages = with pkgs; [
          hidapi
        ];
      };

      # Skip the daily upgrade while a Steam game runs (Steam starts every game under `reaper`)
      systemd.services.nixos-upgrade.serviceConfig.ExecCondition =
        pkgs.writeShellScript "no-steam-game" "! ${pkgs.procps}/bin/pgrep -x reaper";
    };
}
