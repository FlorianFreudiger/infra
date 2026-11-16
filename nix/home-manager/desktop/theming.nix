{ inputs, ... }:
{
  flake.homeModules.theming =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      home.packages = with pkgs; [
        (catppuccin-kde.override {
          flavour = [
            "latte"
            "frappe"
            "macchiato"
            "mocha"
          ];
          accents = [ config.catppuccin.accent ];
        })
      ];

      catppuccin = {
        enable = true;
        cursors.enable = true;

        # Use nixpkgs builds to avoid long build times (override from catppuccin/nix#1012)
        sources = inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.overrideScope (
          _: _: {
            cursors = pkgs.catppuccin-cursors;
            whiskers = pkgs.catppuccin-whiskers;
          }
        );
      };

      services.tailscale-systray.theme =
        if config.catppuccin.flavor == "latte" then "light:nobg" else "dark:nobg";
    };
}
