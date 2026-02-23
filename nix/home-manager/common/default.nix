{ ... }:
{
  flake.homeModules.default =
    { ... }:
    {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
}
