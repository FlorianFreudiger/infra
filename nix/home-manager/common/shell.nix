{ ... }:
{
  flake.homeModules.shell =
    { pkgs, ... }:
    {
      # Shell
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting

          function fish_should_add_to_history
              # Skip if starts with space (default behavior)
              string match -qr '^\\s' -- $argv; and return 1

              # Do not remember power commands
              set -l cmd (string split -n ' ' -- $argv[1])
              test "$cmd[1]" = sudo; and set -e cmd[1]
              switch "$cmd[1]"
                case halt poweroff reboot shutdown
                  return 1
                case systemctl
                  # First non-option argument is the systemctl command
                  set -l verb (string match -v -- '-*' $cmd[2..])[1]
                  switch "$verb"
                    case emergency halt hibernate hybrid-sleep kexec poweroff reboot rescue sleep soft-reboot suspend suspend-then-hibernate
                      return 1
                  end
              end
              return 0
          end

          # Replace man with batman
          batman --export-env | source
        '';
        plugins = [
          # Jump to frequently used directories
          {
            name = "z";
            src = pkgs.fishPlugins.z.src;
          }

          # Text expansions like ... -> ../.. and !! for previous command
          {
            name = "puffer";
            src = pkgs.fishPlugins.puffer.src;
          }
        ];
      };

      # Terminal multiplexer
      programs.zellij = {
        enable = true;
        settings = {
          # Hide tips and release notes on startup since they block immediate keyboard input
          show_startup_tips = false;
          show_release_notes = false;

          ui = {
            pane_frames = {
              rounded_corners = true;
            };
          };
        };
      };

      # Cat alternative with highlighting
      programs.bat = {
        enable = true;
        extraPackages = with pkgs; [ bat-extras.batman ];
      };

      # Tldr pages for quick command reference
      programs.tealdeer = {
        enable = true;

        # Disable periodic background updates but enable auto updates on demand
        enableAutoUpdates = false;
        settings = {
          updates.auto_update = true;
        };
      };
    };
}
