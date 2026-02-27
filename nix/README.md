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
