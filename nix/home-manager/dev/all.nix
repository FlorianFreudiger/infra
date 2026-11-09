{ self, ... }:
{
  flake.homeModules.dev-all =
    { ... }:
    {
      imports = [
        self.homeModules.dev-ai
        self.homeModules.dev-langs-ansible
        self.homeModules.dev-langs-c-cpp
        self.homeModules.dev-langs-containers
        self.homeModules.dev-langs-nix
        self.homeModules.dev-langs-python
        self.homeModules.dev-langs-rust
      ];
    };
}
