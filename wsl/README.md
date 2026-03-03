# Custom WSL Kernel Builder

Build custom WSL kernel with extra options set.

## Prerequisites (inside WSL)

Example requirement installation for Ubuntu/Debian-based distros:

```bash
sudo apt update
sudo apt install -y build-essential flex bison libssl-dev libelf-dev bc python3 pahole cpio dwarves qemu-utils git
```

## Build

```bash
chmod +x ./build-wsl-kernel.sh
./build-wsl-kernel.sh
```

## Set WSL
1. Set both custom kernel image and modules in the WSL Settings UI
or edit `%UserProfile%\\.wslconfig` on Windows:
```ini
[wsl2]
kernel=C:\\...\\bzImage
kernelModules=C:\\...\\modules.vhdx
```

2. Restart WSL from PowerShell:

```powershell
wsl --shutdown
```

3. Start WSL again and verify:

```bash
uname -r
```
