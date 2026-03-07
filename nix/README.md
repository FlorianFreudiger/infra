## Deploy to new host

1. Build sd image and flash to storage media
2. Boot host and wait for it to be reachable via ssh
3. Define new host in `nixos/systems/<hostname>.nix`, use `nixos-generate-config --show-hardware-config` on new host to get hardware-configuration
4. Rekey relevant secrets via host-key:

```bash
# Your machine
mkdir -p ./secrets/hosts/<hostname>
scp <user>@<host>:/etc/ssh/ssh_host_ed25519_key.pub ./secrets/hosts/<hostname>
git -C ./secrets add hosts/<hostname>
nix develop
agenix rekey
git -C ./secrets add rekeyed/<hostname>
```

5. Copy over nixos configuration to host:

While we could also deploy remotely, this way we have a local copy and auto-upgrades work

```bash
# Your machine
ssh <user>@<host> sudo chown <user> /etc/nixos
rsync -a --progress -e ssh --exclude='result*' --exclude='*.img' ./ <user>@<host>:/etc/nixos
```

6. Connect to host and switch to the new configuration:

```bash
# New host
cd /etc/nixos
tmux
nh os switch . --hostname <hostname> <--ask>
```

7. Restart system to apply boot changes: `sudo reboot`


## Building an aarch64 SD bootstrap image

There are multiple ways to build the aarch64 SD bootstrap image below.

Result image artifact will be available in `./result/sd-image/`.
You can decompress it via `unzstd -o nixos-bootstrap-sd-aarch64.img result/sd-image/<img-name>.img.zst` 

### 1. Build on native aarch64 linux host (fast)

If you have a fast native aarch64 nix build host available, you can just build the image directly on it without needing to set up any emulation or cross-compilation.

```bash
nix build .#images.bootstrap-sd-aarch64
```

### 2. Using binary emulation on x64 linux host (medium)

- Positive: While binary emulation is slower than cross-compilation, here we can use the nix cache which has precompiled binaries for aarch64
- Negative: You need to set up binary emulation on your host system

On NixOS enable the binfmt wrapper for aarch64 in your configuration.nix:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

Reboot the system, then build:

```bash
nix build .#images.bootstrap-sd-aarch64
```

### 3. Cross-compilation on x64 linux host (slow)

- Positive: Using this you can cross-compile from x64 without needing to have binary emulation set up
- Negative: But you will need to compile EVERYTHING from scratch for the target platform which is very slow

```bash
nix build .#images.bootstrap-sd-aarch64-from-x64
```


## Secrets

Secrets are stored in private repo submodule `nix-secrets` placed in the `secrets` directory.
You may remove it or replace it with your own secrets repo if you want to use this setup for yourself.

### Setting up yubikey age-identities in WSL
1. Install `agenix-pugin-yubikey` in Windows via `cargo install age-plugin-yubikey`
2. In WSL: `mkdir -p ~/.config/age`
3. Connect primary yubikey
4. In WSL: `age-plugin-yubikey.exe --identity --slot 1 > ~/.config/age/yubikey-primary.txt`
5. Disconnect primary yubikey, connect backup yubikey
6. In WSL: `age-plugin-yubikey.exe --identity --slot 1 > ~/.config/age/yubikey-backup.txt`

### Editing secrets
```bash
nix develop
agenix edit secrets/master/...
```

### Rekeying secrets
```bash
nix develop
agenix rekey
```
After rekeying don't forget to add rekeyed keys to the (submodule) repo.
