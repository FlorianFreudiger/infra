{ self, ... }:
{
  flake.homeModules.desktop =
    { ... }:
    {
      imports = [
        self.homeModules.development # Inherit development profile
        self.homeModules.desktop-apps
        self.homeModules.browser
      ];
    };
}
