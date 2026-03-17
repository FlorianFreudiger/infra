{ ... }:
{
  flake.homeModules.shell =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting
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
    };
}
