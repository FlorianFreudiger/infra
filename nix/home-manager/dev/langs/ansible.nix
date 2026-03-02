{ ... }:
{
  flake.homeModules.dev-langs-ansible =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ansible
        ansible-lint
      ];
    };
}
