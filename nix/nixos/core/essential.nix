{ inputs, ... }:
{
  flake.nixosModules.essential =
    { pkgs, ... }:
    {
      nix = {
        settings = {
          # Enable nix-command and flakes
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          # De-duplicate files in store via hardlinks
          auto-optimise-store = true;
        };

        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 30d";
        };
      };

      system.autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        dates = "03:00";
        randomizedDelaySec = "15min";
        allowReboot = false;
      };

      time.timeZone = "Europe/Berlin";

      # Packages:

      environment.systemPackages = with pkgs; [
        # For editing nix config
        nixd
        nixfmt

        # For general use
        wget
        ncdu
        fastfetch
        jq

        # Administration
        kmod
      ];

      programs.nix-ld.enable = true;
      programs.nh.enable = true;
      programs.git = {
        enable = true;
        lfs.enable = true;
      };
      programs.htop = {
        enable = true;
        settings = {
          hide_kernel_threads = true;
          hide_userland_threads = true;
          enable_mouse = true;
          tree_view = true;
          fields = [
            0
            48
            46
            47
            49
            1
          ];
          highlight_base_name = true;
          highlight_changes = true;
          highlight_changes_delay_secs = 1;
        };
      };
      programs.tmux = {
        enable = true;
        clock24 = true;
        historyLimit = 5000; # Up from default 2000
        extraConfig = "set -g mouse on";
      };
    };
}
