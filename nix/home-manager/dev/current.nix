{ self, ... }:
{
  flake.homeModules.dev-current =
    { ... }:
    {
      imports = [
        self.homeModules.dev-ai
        self.homeModules.dev-langs-nix
        self.homeModules.dev-langs-python
      ];
    };
}
