{ self, ... }:
{
  flake.homeModules.dev-all =
    { ... }:
    {
      imports = [
        self.homeModules.dev-langs-ansible
        self.homeModules.dev-langs-python
      ];
    };
}
