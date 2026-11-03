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

        (heroic.override {
          extraPkgs =
            pkgs: with pkgs; [
              gamemode
            ];
        })
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

      # Skip some automated tasks while a game runs
      # - Steam starts every game under `reaper`
      # - Heroic runs Epic games through Wine/Proton, which keeps a `wineserver` alive
      # - PrismLauncher starts Minecraft as `java ... org.prismlauncher.EntryPoint`
      systemd.services =
        lib.genAttrs
          [
            "nixos-upgrade"
            "nix-gc"
          ]
          (_: {
            serviceConfig.ExecCondition = [
              (pkgs.writeShellScript "no-game-running" ''
                ! ${pkgs.procps}/bin/pgrep -x 'reaper|wineserver' &&
                ! ${pkgs.procps}/bin/pgrep -f 'org\.prismlauncher\.EntryPoint'
              '')
            ];
          });
    };
}
