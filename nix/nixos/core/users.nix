{ ... }:
{
  flake.nixosModules.users =
    { lib, pkgs, ... }:
    let
      authorizedKeysDir = ../../secrets/authorized_keys/turtle;
      authorizedKeysFiles = lib.fileset.toList (
        lib.fileset.fileFilter (file: file.hasExt "pub") authorizedKeysDir
      );
    in
    {
      users.users = {
        turtle = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          shell = pkgs.fish;
          openssh.authorizedKeys.keyFiles = authorizedKeysFiles;
        };
      };

      # Allow members of wheel group to sudo without password
      # Needed if no password is set
      security.sudo.wheelNeedsPassword = false;

      # Enable needed shells
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];
    };
}
