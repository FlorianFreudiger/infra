{ inputs, self, ... }:
{
  flake.nixosModules.wsl =
    { ... }:
    {
      imports = [
        self.nixosModules.essential
        self.nixosModules.home-manager
        self.nixosModules.ssh
        self.nixosModules.secrets
        self.nixosModules.network
        self.nixosModules.security
        inputs.nixos-wsl.nixosModules.wsl
      ];

      wsl.enable = true;
      wsl.defaultUser = "turtle";
      # Integrate with Docker Desktop running on Windows, does not install docker in NixOS
      wsl.docker-desktop.enable = true;
    };
}
