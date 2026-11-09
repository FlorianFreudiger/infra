{ inputs, ... }:
{
  flake.homeModules.dev-langs-nix =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        nil
        nixd
        nixfmt
      ];

      programs.zed-editor.extensions = [ "nix" ];
      # Add home-manager module of host in nixd LSP
      programs.zed-editor.userSettings.lsp.nixd.settings.options.home-manager.expr = ''
        (import ${inputs.home-manager}/modules {
          pkgs = import ${inputs.nixpkgs} { };
          configuration = {
            home.username = "${config.home.username}";
            home.homeDirectory = "${config.home.homeDirectory}";
            home.stateVersion = "${config.home.stateVersion}";
          };
        }).options
      '';
    };
}
