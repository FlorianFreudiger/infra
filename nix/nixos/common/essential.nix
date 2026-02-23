{ ... }:
{
  flake.nixosModules.essential =
    { pkgs, ... }:
    {
      # Enable nix-command and flakes
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      time.timeZone = "Europe/Berlin";

      # Packages:

      environment.systemPackages = with pkgs; [
        # For editing nix config
        nixd
        nixfmt

        # For general use
        wget
        ncdu
      ];

      programs.nix-ld.enable = true;
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
