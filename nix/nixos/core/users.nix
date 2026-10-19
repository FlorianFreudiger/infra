{ ... }:
{
  flake.nixosModules.users =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    let
      usersDir = ../../secrets/users;

      # Optionally restrict users to certain hosts
      onHosts = hosts: lib.mkIf (lib.elem config.networking.hostName hosts);

      # Map of user to their files in secrets/users/<user>
      userSecrets = lib.mapAttrs (user: _: {
        # Public keys in authorized_keys/*.pub
        authorizedKeysFiles = lib.fileset.toList (
          lib.fileset.fileFilter (file: file.hasExt "pub") (usersDir + "/${user}/authorized_keys")
        );

        # Decrypted hashed-password.age, declared in the secrets module
        # If Agenix is not loaded, like in the bootstrap profile, users get no password
        hashedPasswordFile =
          if options ? age then config.age.secrets."users-${user}-hashed-password".path else null;
      }) (builtins.readDir usersDir);

      # Users whose hashedPasswordFile is enforced below
      enforcedPasswordUsers = lib.filterAttrs (
        _: user: user.enforcePassword && user.hashedPasswordFile != null
      ) config.users.users;
    in
    {
      # Additional per-user options
      options.users.users = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.enforcePassword = lib.mkEnableOption "Apply hashedPasswordFile on every activation";
          }
        );
      };

      config = {
        users = {
          # Let users change their own password
          # Users with custom option "enforcePassword" will get their declared password reapplied below
          mutableUsers = true;

          users = {
            turtle = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              shell = pkgs.fish;
              openssh.authorizedKeys.keyFiles = userSecrets.turtle.authorizedKeysFiles;
              hashedPasswordFile = userSecrets.turtle.hashedPasswordFile;
              enforcePassword = true; # Custom option, declared above
            };

            artistic = onHosts [ "pepper" ] {
              isNormalUser = true;
              shell = pkgs.fish;
              # Initial password only
              hashedPasswordFile = userSecrets.artistic.hashedPasswordFile;
            };
          };
        };

        # Reapply passwords of users with enforcePassword
        system.activationScripts.enforcePasswords = lib.mkIf (enforcedPasswordUsers != { }) (
          lib.stringAfter [ "users" ] (
            lib.concatStrings (
              lib.mapAttrsToList (name: user: ''
                if [ -s ${lib.escapeShellArg user.hashedPasswordFile} ]; then
                  ${pkgs.shadow}/bin/usermod --password "$(< ${lib.escapeShellArg user.hashedPasswordFile})" ${lib.escapeShellArg name}
                fi
              '') enforcedPasswordUsers
            )
          )
        );

        # Enable needed shells
        programs.fish.enable = true;
        environment.shells = [ pkgs.fish ];
      };
    };
}
