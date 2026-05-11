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
      ];
    };
}
