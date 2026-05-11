{ ... }:
{
  flake.homeModules.shell =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting

          function fish_should_add_to_history
              # Skip if starts with space (default behavior)
              string match -qr '^\\s' -- $argv; and return 1

              # Do not remember power commands
              set -l argc (count $argv)
              if test $argc -ge 2 -a $argv[1] = sudo
                switch $argv[2]
                  case reboot shutdown poweroff
                    return 1
                end
              end
              return 0
          end
        '';
        plugins = [
          # Make prompt async
          {
            name = "async-prompt";
            src = pkgs.fishPlugins.async-prompt.src;
          }

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
    };
}
