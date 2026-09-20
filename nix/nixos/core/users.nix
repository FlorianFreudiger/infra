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
      users = {
        # Replace users present already
        mutableUsers = false;

        users = {
          turtle = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            shell = pkgs.fish;
            openssh.authorizedKeys.keyFiles = authorizedKeysFiles;
            # User password is set in the secrets module, as it requires agenix being loaded
            # which is not available in the bootstrap profile, which loads this module.
          };
        };
      };

      # Enable needed shells
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];
    };
}
