{ self, ... }:
{
  flake.homeModules.development =
    { ... }:
    {
      imports = [
        self.homeModules.default
        self.homeModules.shell
        self.homeModules.dev-all
      ];
    };
}
