{ ... }:
{
  flake.homeModules.dev-langs-rust =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        rustc
        clang
        pkg-config

        clippy
        rustfmt
        rust-analyzer
      ];

      programs.cargo = {
        enable = true;
        settings.env = {
          LIBCLANG_PATH = "${pkgs.clang.cc.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS = "-idirafter ${pkgs.glibc.dev}/include";
        };
      };

      # Copy rust source into a home directory, required by RustRover, can not be a symlink
      home.activation.rustSrc = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        src=${pkgs.rustPlatform.rustLibSrc}
        dst=${config.xdg.dataHome}/rust-src
        if [[ "$(readlink "$dst/.store-path" 2>/dev/null)" != "$src" ]]; then
          run rm -rf "$dst"
          run mkdir -p "$dst"
          run cp -rL --reflink=auto --no-preserve=mode "$src" "$dst/library"
          run ln -sfn "$src" "$dst/.store-path"
        fi
      '';

      programs.zed-editor.extensions = [ "toml" ];
    };
}
