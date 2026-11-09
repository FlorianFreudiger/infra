{ ... }:
{
  flake.homeModules.dev-langs-containers =
    { ... }:
    {
      programs.zed-editor.extensions = [ "dockerfile" ];
    };
}
