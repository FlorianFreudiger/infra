{ self, ... }:
{
  flake.nixosModules.server =
    { ... }:
    {
      imports = [
        self.nixosModules.backup
        self.nixosModules.containers
        self.nixosModules.essential
        self.nixosModules.facter
        self.nixosModules.home-manager
        self.nixosModules.maintenance
        self.nixosModules.network
        self.nixosModules.options
        self.nixosModules.performance
        self.nixosModules.power-efficiency
        self.nixosModules.secrets
        self.nixosModules.security
        self.nixosModules.ssh
        self.nixosModules.users
      ];
    };
}
