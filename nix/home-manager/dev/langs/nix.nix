{ ... }:
{
  flake.homeModules.dev-langs-nix =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nixd
        nixfmt
      ];
    };
}
