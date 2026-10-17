{ ... }:
{
  flake.nixosModules.users =
    { lib, pkgs, ... }:
    let
      # Map of user to their public keys in secrets/users/<user>/authorized_keys/*.pub
      usersDir = ../../secrets/users;
      authorizedKeysFiles = lib.mapAttrs (
        user: _:
        lib.fileset.toList (
          lib.fileset.fileFilter (file: file.hasExt "pub") (usersDir + "/${user}/authorized_keys")
        )
      ) (builtins.readDir usersDir);
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
            openssh.authorizedKeys.keyFiles = authorizedKeysFiles.turtle;
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
