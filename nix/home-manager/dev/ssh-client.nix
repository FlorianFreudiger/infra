# SSH client base configuration
# Home Manager owns ~/.ssh/config, write unmanaged entries into ~/.ssh/config.d/

{ ... }:
{
  flake.homeModules.ssh-client =
    { lib, ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        # Include unmanaged extra entries. They take precedence.
        includes = [ "config.d/*" ];

        # Defaults for all hosts
        settings."*" = {
          # Reuse one connection per host
          ControlMaster = "auto";
          ControlPath = "~/.ssh/control/%C";
          ControlPersist = "1h"; # Keep open for a while after the last session
        };
      };

      # ssh doesn't create the subdirs itself
      home.activation.sshDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p -m 700 "$HOME/.ssh/config.d" "$HOME/.ssh/control"
      '';
    };
}
