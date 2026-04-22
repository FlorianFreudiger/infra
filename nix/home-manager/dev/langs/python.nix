# Setup Python with:
# - Package managers + linters/formatters/checkers
# - Additional Python packages: For one-off scripts

{ ... }:
{
  flake.homeModules.dev-langs-python =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        (python313.withPackages (
          # Additional Python modules
          python-pkgs: with python-pkgs; [
            argon2-cffi
            cryptography
            dbus-python
            pycryptodome
          ]
        ))

        black # formatter
        isort # formatter
        pyright # type checker
      ];

      programs.poetry.enable = true; # package manager
      programs.uv.enable = true; # package manager
      programs.mypy.enable = true; # type checker
      programs.pylint.enable = true; # linter
    };
}
