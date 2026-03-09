# Custom WSL Kernel Builder

Build custom WSL kernel with extra options set.

Currently only enables Zram support.

## Prerequisites

Example requirement installation for Ubuntu/Debian-based distros:

```bash
# WSL
sudo apt update
sudo apt install -y build-essential flex bison libssl-dev libelf-dev bc python3 pahole cpio dwarves qemu-utils git
```

## Build

```bash
# WSL
chmod +x ./build-wsl-kernel.sh
./build-wsl-kernel.sh
```

## Apply to WSL

0. Optionally check current kernel:

```bash
# WSL
uname -r
```

1. Set both custom kernel image and modules in the WSL Settings UI
or edit `%UserProfile%\\.wslconfig` on Windows:
```ini
[wsl2]
kernel=C:\\...\\bzImage
kernelModules=C:\\...\\modules.vhdx
```

2. Restart WSL from Windows:

```powershell
# PowerShell
wsl --shutdown
```

3. Start WSL again and verify:

```bash
# WSL
uname -r
```
