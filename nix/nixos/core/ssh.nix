{ ... }:
{
  flake.nixosModules.ssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [ "turtle" ];
          KbdInteractiveAuthentication = false;
        };
      };

      services.fail2ban = {
        enable = true;
      };
    };
}
