{ ... }:
{
  # The ASUS ROG Ryujin II AIO has no PWM link to the mainboard and runs at 100% unless told otherwise.
  # The in-tree asus_rog_ryujin hwmon driver exposes its duties, so scale them with the CPU package temp.
  flake.nixosModules.ryujin =
    { pkgs, ... }:
    {
      systemd.services.ryujin-fan-control = {
        description = "Scale ASUS Ryujin II pump and fans with CPU temperature";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "ryujin-fan-control" ''
            set -eu

            # Idle duties at or below LOW, full speed at or above HIGH (millidegrees Celsius)
            LOW=50000 HIGH=90000

            # hwmonN numbers aren't stable across boots, so look them up by name
            for h in /sys/class/hwmon/hwmon*; do
              case $(< "$h/name") in
                coretemp) cpu=$h/temp1_input ;; # Package id 0
                rog_ryujin) aio=$h ;;
              esac
            done

            t=$(< "$cpu")
            while true; do
              # ~16s moving average, so short package temp spikes don't rev the fans
              t=$(( t + ($(< "$cpu") - t) / 8 ))
              f=$(( (t - LOW) * 255 / (HIGH - LOW) ))
              f=$(( f < 0 ? 0 : f > 255 ? 255 : f ))

              # Rewritten every loop, since the AIO resets to 100% when it loses power (e.g. suspend)
              echo $(( 51 + 204 * f / 255 )) > "$aio/pwm1" # pump, 20% idle
              echo $f > "$aio/pwm2"                        # internal fan, off at idle
              echo $(( 51 + 204 * f / 255 )) > "$aio/pwm3" # radiator fans, 20% idle
              sleep 2
            done
          '';
          # Also covers the AIO not being enumerated yet, or vanishing on USB reset
          Restart = "always";
          RestartSec = 5;
        };
      };
    };
}
