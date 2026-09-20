# Try to improve system security through various means
# - Add programs to check for potential security issues
# - Ensure firewall is enabled
# - Harden sudo
# - Harden kernel

{ ... }:
{
  flake.nixosModules.security =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        kernel-hardening-checker
        lynis
      ];

      # Ensure firewall is enabled
      networking.firewall.enable = lib.mkForce true;

      security = {
        sudo = {
          # Harden sudo, only allow members of wheel group to execute sudo
          execWheelOnly = true;

          # Do not require repeating password in the same session for some time
          extraConfig = "Defaults timestamp_timeout=60";

          # Require password
          wheelNeedsPassword = true;

          # Fall back to sudo if sudo-rs gets disabled somewhere else
          enable = !config.security.sudo-rs.enable;
        };

        # Switch to sudo-rs
        sudo-rs = {
          enable = true;

          # Copy over relevant sudo options
          execWheelOnly = config.security.sudo.execWheelOnly;
          extraConfig = config.security.sudo.extraConfig;
          wheelNeedsPassword = config.security.sudo.wheelNeedsPassword;
        };
      };

      # Kernel hardening
      boot.blacklistedKernelModules = [
        # Filesystem modules
        # "9p" # Enabled: VM filesystem sharing
        "adfs"
        "affs"
        "afs"
        # "autofs4" # Enabled: auto-mounting filesystem support
        "bcachefs"
        "befs"
        "bfs"
        # "btrfs" # Enabled: Root filesystem
        # "cachefiles" # Enabled: FS caching, often for NFS
        "ceph"
        "coda"
        "cramfs"
        "dlm"
        # "efivarfs" # Enabled: UEFI
        "efs"
        "erofs"
        # "exfat" # Enabled: External drives
        "ext2"
        # "ext4" # Enabled: Root filesystem
        # "f2fs" # Enabled: Root filesystem
        # "fat" # Enabled: External drives
        "freevxfs"
        # "fuse" # Enabled: user-space filesystems
        "gfs2"
        "hfs"
        "hfsplus"
        "hpfs"
        # "isofs" # Enabled: Optical drives
        "jffs2"
        "jfs"
        # "lockd" # Enabled: NFS related
        "minix"
        "netfs"
        # "nfs" # Enabled: NFS client
        # "nfsd" # Enabled: NFS server
        "nilfs2"
        # "ntfs" # Enabled: Windows drives
        # "ntfs3" # Enabled: Windows drives
        "ocfs2"
        "omfs"
        "orangefs"
        # "overlay" # Enabled: Containers and others
        "qnx4"
        "qnx6"
        "reiserfs"
        "romfs"
        "sysv"
        "ubifs"
        # "udf" # Enabled: Optical drives
        "ufs"
        # "vboxsf" # Enabled: VirtualBox shared folders
        # "vfat" # Enabled: External drives and UEFI
        # "xfs" # Enabled: Root filesystem
        "zonefs"

        # Network modules
        "appletalk"
        "atm"
        "ax25"
        "can"
        "netrom"
        "rds"
        "rose"
        "sctp"
        "tipc"
        "x25"

        # Other modules
        "firewire_core"
        "firewire_net"
        "firewire_ohci"
        "firewire_sbp2"
      ];

      boot.kernel.sysctl = {
        "dev.tty.ldisc_autoload" = 0; # Disable automatic loading of line discipline modules
        "fs.suid_dumpable" = 0; # Disable core dumps for setuid programs
        "kernel.dmesg_restrict" = 1; # Restrict access to dmesg to CAP_SYSLOG
        "kernel.kexec_load_disabled" = 1; # Disable loading new kernel via kexec
      };
    };
}
