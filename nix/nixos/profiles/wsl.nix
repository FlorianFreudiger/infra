{ inputs, self, ... }:
{
  flake.nixosModules.wsl =
    { ... }:
    {
      imports = [
        self.nixosModules.essential
        self.nixosModules.users
        self.nixosModules.home-manager
        self.nixosModules.ssh
        self.nixosModules.secrets
        self.nixosModules.network
        self.nixosModules.performance
        self.nixosModules.security
        self.nixosModules.backup
        # no containers module as docker is passed through from Windows
        inputs.nixos-wsl.nixosModules.wsl
      ];

      wsl.enable = true;
      wsl.defaultUser = "turtle";
      # Integrate with Docker Desktop running on Windows, does not install docker in NixOS
      wsl.docker-desktop.enable = true;

      # Set security-key helper to enable SSH authentication when using e.g. sk-ssh-ed25519 keys
      environment.sessionVariables = {
        SSH_SK_HELPER = "/mnt/c/Program Files/OpenSSH/ssh-sk-helper.exe";
      };
    };
}
