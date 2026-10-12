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

      # Add terminfo for other terminals like ghostty, kitty, etc. to avoid terminal issues
      environment.enableAllTerminfo = true;

      services.fail2ban = {
        enable = true;
      };
    };
}
