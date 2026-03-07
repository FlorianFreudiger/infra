{ self, ... }:
{
  flake.nixosModules.server =
    { ... }:
    {
      imports = [
        self.nixosModules.backup
        self.nixosModules.containers
        self.nixosModules.essential
        # no home-manager module
        self.nixosModules.maintenance
        self.nixosModules.network
        self.nixosModules.performance
        self.nixosModules.secrets
        self.nixosModules.security
        self.nixosModules.ssh
        self.nixosModules.users
      ];
    };
}
