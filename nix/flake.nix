{
  description = "NixOS flake for my infrastructure";

  inputs = {
    # Enable submodules to allow accessing private secrets dir
    self.submodules = true;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = "";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nixpkgs-kopia = {
      url = "github:efficacy38/nixpkgs/7ae5970634a00b96ee407e9e426641bdfc182a25";
      flake = false;
    };
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        (inputs.import-tree ./nixos)

        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./home-manager)

        inputs.agenix-rekey.flakeModule
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          # Devshell for editing age/agenix secrets.
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              config.agenix-rekey.package

              # Redirect age-plugin-yubikey to Windows exe if available (for WSL).
              (pkgs.writeShellScriptBin "age-plugin-yubikey" ''
                if command -v age-plugin-yubikey.exe &> /dev/null; then
                  exec age-plugin-yubikey.exe "$@"
                else
                  exec ${pkgs.age-plugin-yubikey}/bin/age-plugin-yubikey "$@"
                fi
              '')
            ];
          };
        };
    };
}
