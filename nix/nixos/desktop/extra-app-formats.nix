# Support additional application formats
# - nix-ld: Run unpatched dynamic binaries on NixOS
# - AppImage support
# - Flatpak support

{ ... }:
{
  flake.nixosModules.extra-app-formats =
    {
      pkgs,
      options,
      lib,
      ...
    }:
    {
      ## nix-ld ##
      programs.nix-ld = {
        enable = true;

        # Extra libraries to become available
        libraries = lib.unique (
          # Include default libraries
          options.programs.nix-ld.libraries.default

          # Include all libraries also expected by AppImages
          # This fixes running Jetbrains tools when installed via Jetbrains Toolbox
          ++ (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)

          # Extra libraries
          ++ (with pkgs; [
            libsecret
          ])
        );
      };

      ## AppImage ##
      programs.appimage = {
        # Enable appimage-run wrapper script to run AppImages
        enable = true;

        # Automatically use appimage-run when executing AppImages
        binfmt = true;
      };

      ## Flatpak ##
      services.flatpak.enable = true;

      # Add flathub repo automatically
      systemd.services.flatpak-add-flathub-repo = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];

        # Skip if flathub is already added, assuming config file is at default location
        unitConfig.ConditionPathExists = [ "/var/lib/flatpak/repo/config" ];
        serviceConfig.ExecCondition = [
          "${pkgs.bash}/bin/bash -c \"! ${pkgs.gnugrep}/bin/grep -qF '[remote \\\"flathub\\\"]' /var/lib/flatpak/repo/config\""
        ];

        script = ''
          set -euo pipefail
          flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        '';
      };
    };
}
