{ ... }:
{
  flake.nixosModules.security =
    { config, ... }:
    {
      # Ensure firewall is enabled
      networking.firewall.enable = true;

      security = {
        sudo = {
          # Harden sudo, only allow members of wheel group to execute sudo
          execWheelOnly = true;

          # Fall back to sudo if sudo-rs gets disabled somewhere else
          enable = !config.security.sudo-rs.enable;
        };

        # Switch to sudo-rs
        sudo-rs = {
          enable = true;

          # Copy over relevant sudo options
          execWheelOnly = config.security.sudo.execWheelOnly;
          wheelNeedsPassword = config.security.sudo.wheelNeedsPassword;
        };
      };
    };
}
