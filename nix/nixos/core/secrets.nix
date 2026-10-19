{ self, inputs, ... }:
{
  flake.nixosModules.secrets =
    { config, lib, ... }:
    let
      hostPubkeyPath = self + "/secrets/hosts/${config.networking.hostName}/ssh_host_ed25519_key.pub";
      hashedPasswordPath = user: self + "/secrets/users/${user}/hashed-password.age";
    in
    {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ];

      age.rekey = {
        masterIdentities = [
          "${config.users.users.turtle.home}/.config/age/yubikey-primary.txt"
          "${config.users.users.turtle.home}/.config/age/yubikey-backup.txt"
        ];
        storageMode = "local";
        localStorageDir = self + "/secrets/rekeyed/${config.networking.hostName}";
      }
      // lib.optionalAttrs (builtins.pathExists hostPubkeyPath) {
        # Keep this as file contents (not a store path) so hashing stays stable.
        # If the file does not exist yet, omit hostPubkey and let agenix-rekey
        # use its dummy key for first-time bootstrap.
        hostPubkey = builtins.readFile hostPubkeyPath;
      };

      # Hashed passwords of users on this host, used in the users module
      age.secrets = lib.mapAttrs' (
        user: _: lib.nameValuePair "users-${user}-hashed-password" { rekeyFile = hashedPasswordPath user; }
      ) (lib.filterAttrs (user: _: builtins.pathExists (hashedPasswordPath user)) config.users.users);
    };
}
