{ ... }:
{
  flake.homeModules.dev-langs-c-cpp =
    { lib, pkgs, ... }:
    {
      home.packages = with pkgs; [
        clang
        clang-tools

        # Build tools/systems
        gnumake
        cmake
        meson
        ninja

        # Debugging tools
        gdb
        strace

        # Documentation
        man-pages
      ];

      programs.gcc = {
        enable = true;
        package = lib.hiPrio pkgs.gcc; # Prefer over clang
      };

      programs.zed-editor.extensions = [ "make" ];
    };
}
