# Kernel development without dev shell
# Build tools and libraries are only available inside these commands
# Each compiler has its own build dir and .config, since Kconfig records compiler-specific options
# Both build with -j$(nproc), a later -jN overrides it
#
# kmake-clang ...:
# - Builds into .build-clang
# - Without arguments: builds all + compile_commands.json for clangd
# - For clangd, once per tree: `printf 'CompileFlags:\n  CompilationDatabase: .build-clang\n' > .clangd`
#
# kmake-gcc ...:
# - Builds into .build-gcc

{ ... }:
{
  flake.homeModules.dev-langs-kernel-development =
    { lib, pkgs, ... }:
    {
      home.packages =
        let
          # Libraries for build tools
          libs = with pkgs; [
            elfutils
            ncurses
            openssl
            zlib
          ];

          # Store paths instead of profile paths
          exportLibs = libraries: ''
            export CPATH=${lib.makeSearchPathOutput "dev" "include" libraries}
            export LIBRARY_PATH=${lib.makeLibraryPath libraries}
            export PKG_CONFIG_PATH=${lib.makeSearchPathOutput "dev" "lib/pkgconfig" libraries}
            PKG_CONFIG_PATH+=:${lib.makeSearchPathOutput "dev" "share/pkgconfig" libraries}
          '';

          # Common build tools
          tools = with pkgs; [
            bc
            bison
            coreutils # nproc
            cpio
            flex
            gnumake
            kmod
            openssl
            pahole
            perl
            pkg-config
            python3
            rsync
            zstd
          ];
        in
        [
          (pkgs.writeShellApplication {
            name = "kmake-clang";
            runtimeInputs =
              tools
              ++ (with pkgs; [
                clang # HOSTCC
                lld
                llvm
              ]);
            text = ''
              ${exportLibs libs}
              # Out-of-tree build, O=... still overrides it
              export KBUILD_OUTPUT="''${KBUILD_OUTPUT:-.build-clang}"

              # No arguments: build everything and compile_commands.json
              if [ $# -eq 0 ]; then set -- all compile_commands.json; fi

              # Use unwrapped clang, since wrapped clang includes incompatible flags for kernel build
              exec make -j"$(nproc)" LLVM=1 CC=${pkgs.clang.cc}/bin/clang "$@"
            '';
          })

          (pkgs.writeShellApplication {
            name = "kmake-gcc";
            runtimeInputs = tools ++ [ pkgs.gcc ]; # Includes ld, ar, nm, objcopy
            text = ''
              ${exportLibs (
                libs
                ++ (with pkgs; [
                  # GCC plugins
                  gmp
                  libmpc
                  mpfr
                ])
              )}
              # Out-of-tree build, O=... still overrides it
              export KBUILD_OUTPUT="''${KBUILD_OUTPUT:-.build-gcc}"

              exec make -j"$(nproc)" "$@"
            '';
          })
        ];
    };
}
