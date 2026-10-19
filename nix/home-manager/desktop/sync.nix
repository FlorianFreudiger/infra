{ self, ... }:
{
  flake.homeModules.sync =
    {
      config,
      lib,
      osConfig,
      ...
    }:
    let
      # Keep syncthing devices, folders and GUI password of this user in secrets
      syncthing = import (self + "/secrets/users/${config.home.username}/syncthing.nix");
    in
    {
      # Keep an option available to exclude this device from device list if hostname is not set
      options.infra.syncthing.deviceName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = osConfig.networking.hostName or null;
      };

      config.services.syncthing = {
        enable = true;

        # Keep devices and folders added in the web interface
        overrideDevices = false;
        overrideFolders = false;

        guiCredentials = {
          username = config.home.username;
          passwordFile = builtins.toFile "syncthing-gui-password-hash" syncthing.guiPasswordHash;
        };

        settings = {
          # Exclude this device from devices
          devices = lib.filterAttrs (name: _: name != config.infra.syncthing.deviceName) syncthing.devices;

          # Only enable folders this host is listed in and remove this host from the devices list of those folders
          folders = lib.mapAttrs (
            _: folder:
            folder
            // {
              enable = lib.elem config.infra.syncthing.deviceName folder.devices;
              devices = lib.filter (peer: peer != config.infra.syncthing.deviceName) folder.devices;
            }
          ) syncthing.folders;

          options = {
            # Opt out of submitting usage statistics
            urAccepted = -1;
          };
        };

        tray.enable = true;
      };
    };
}
