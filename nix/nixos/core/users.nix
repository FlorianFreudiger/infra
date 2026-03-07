{ ... }:
{
  flake.nixosModules.users =
    { lib, ... }:
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

          openssh.authorizedKeys.keyFiles = authorizedKeysFiles;
        };
      };

      # Allow members of wheel group to sudo without password
      # Needed if no password is set
      security.sudo.wheelNeedsPassword = false;
    };
}
