# SSH client configuration for YubiKeys
# Enroll YubiKey ssh keys on each host once,
# then when a YubiKey is plugged in, the service will
# 1. Link the plugged-in YubiKey's keys into ~/.ssh/yubikeys/active
# 2. Add the active keys to the ssh-agent, remove the old ones

{ ... }:
{
  flake.homeModules.ssh-client =
    { lib, pkgs, ... }:
    let
      git-forges = [
        "codeberg.org"
        "github.com"
        "gitlab.com"
      ];
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          yubikey-login = {
            header = "Host * ${lib.concatMapStringsSep " " (forge: "!${forge}") git-forges}";
            IdentitiesOnly = true;
            IdentityFile = "~/.ssh/yubikeys/active/id_ed25519_sk_rk_login_%u";
          };

          yubikey-git = {
            header = "Host ${lib.concatStringsSep " " git-forges}";
            IdentitiesOnly = true;
            IdentityFile = "~/.ssh/yubikeys/active/id_ed25519_sk_rk_git_%u";
          };
        };
      };

      services.ssh-agent.enable = true;

      # The agent has no terminal, so it asks for PINs through ksshaskpass.
      systemd.user.services.ssh-agent.Service.Environment = [
        "SSH_ASKPASS_REQUIRE=force"
        "SSH_ASKPASS=${
          lib.getExe (
            pkgs.writeShellApplication {
              name = "ksshaskpass-wayland";
              runtimeInputs = with pkgs; [
                systemd
                gnugrep
                kdePackages.ksshaskpass
              ];
              text = ''
                # The agent starts before Plasma, so look up the Wayland display at prompt time
                WAYLAND_DISPLAY=$(systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')
                export WAYLAND_DISPLAY

                # Remove the session bus, so ksshaskpass can't store the PIN in KWallet
                export DBUS_SESSION_BUS_ADDRESS=unix:path=/nonexistent

                exec ksshaskpass "$@"
              '';
            }
          )
        }"
      ];

      home.packages = [
        (pkgs.writeShellApplication {
          name = "yubikey-ssh-enroll";
          runtimeInputs = with pkgs; [
            yubikey-manager
            openssh
            coreutils
            systemd
          ];
          text = ''
            # Extract serial number of Yubikey and create dir for its keys
            serial=$(ykman list --serials 2>/dev/null) || true
            if ! [[ $serial =~ ^[0-9]+$ ]]; then
              echo "Plug in exactly one YubiKey." >&2
              exit 1
            fi
            dir=~/.ssh/yubikeys/$serial

            # Replace old stubs with new ones
            ssh-add -qd "$dir"/*.pub 2>/dev/null || true
            rm -rf "$dir"
            mkdir -p "$dir"
            cd "$dir"
            ssh-keygen -K -N ""

            # Restart sync service to pick up the new stubs
            systemctl --user restart yubikey-agent-sync
          '';
        })
      ];

      systemd.user.services.yubikey-agent-sync = {
        Unit = {
          Description = "Sync ssh keys to the currently plugged-in YubiKey";
          After = [ "ssh-agent.service" ];
          BindsTo = [ "ssh-agent.service" ];
        };
        Install.WantedBy = [ "ssh-agent.service" ];
        Service = {
          Restart = "always";
          Environment = "SSH_AUTH_SOCK=%t/ssh-agent";
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "yubikey-agent-sync";
              runtimeInputs = with pkgs; [
                yubikey-manager
                openssh
                systemd
                coreutils
              ];
              text = ''
                set +e # one failing ssh-add must not stop the service
                mkdir -p ~/.ssh/yubikeys
                cd ~/.ssh/yubikeys || exit

                # Update active keys
                update() {
                  new=""
                  for serial in $(ykman list --serials 2>/dev/null); do
                    if [[ -d $serial ]]; then new=$serial; break; fi
                  done
                  old=$(readlink active)
                  [[ $new == "$old" ]] && return # e.g. some other HID device was plugged in

                  # Load new keys, unload old keys, update symlink
                  if [[ -n $new ]]; then
                    pubs=("$new"/*.pub)
                    ssh-add -q "''${pubs[@]%.pub}" # each stub sits next to its .pub
                    ln -sfn "$new" active.new && mv -T active.new active
                  else
                    rm -f active
                  fi
                  [[ -n $old ]] && ssh-add -qd "$old"/*.pub 2>/dev/null
                }

                # After start, update once, then wait for plugged-in events
                while [[ ! -S $SSH_AUTH_SOCK ]]; do sleep 0.2; done
                ssh-add -qd active/*.pub 2>/dev/null
                rm -f active
                update
                udevadm monitor --udev --subsystem-match=hidraw | while read -r event; do
                  [[ $event == *"(hidraw)" ]] && sleep 1 && update
                done
              '';
            }
          );
        };
      };
    };
}
