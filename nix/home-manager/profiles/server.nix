{ self, ... }:
{
  flake.homeModules.server =
    { ... }:
    {
      imports = [
        self.homeModules.default
        self.homeModules.shell
      ];
    };
}
