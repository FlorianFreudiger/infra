{ ... }:
{
  flake.homeModules.dev-langs-python =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        python3
        black
        isort
        pyright
      ];
      programs.pylint.enable = true;
      programs.mypy.enable = true;

      # Python package managers
      programs.poetry.enable = true;
      programs.uv.enable = true;
    };
}
