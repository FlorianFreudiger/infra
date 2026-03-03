#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/microsoft/WSL2-Linux-Kernel.git"
BRANCH="linux-msft-wsl-6.6.y"
WORKDIR="${HOME}/wsl-kernel"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$WORKDIR"
if [[ ! -d "$WORKDIR/.git" ]]; then
  echo "-- Cloning WSL kernel repo"
  git clone "$REPO" "$WORKDIR" --depth 1 -b "$BRANCH"
else
  echo "-- Pulling latest changes"
  git -C "$WORKDIR" pull
fi

echo "-- Copying config and applying changes"
cp "$WORKDIR/Microsoft/config-wsl" "$WORKDIR/.config"
cat "$SCRIPT_DIR/config-changes.config" >> "$WORKDIR/.config"

echo "-- Building kernel image"
make -C "$WORKDIR" -j$(nproc) -s
mkdir -p "$SCRIPT_DIR/out"
cp "$WORKDIR/arch/x86/boot/bzImage" "$SCRIPT_DIR/out/bzImage"

echo "-- Building kernel modules"
make -C "$WORKDIR" -j"$(nproc)" -s modules
MODULES_OUTDIR="${WORKDIR}/output"
make -C "$WORKDIR" -j"$(nproc)" -s INSTALL_MOD_PATH="$MODULES_OUTDIR" modules_install
rm -f "$MODULES_OUTDIR"/lib/modules/*/build
rm -f "$MODULES_OUTDIR"/lib/modules/*/source

echo "-- Generating modules.vhdx (sudo required)"
KERNEL_RELEASE="$(make -s -C "$WORKDIR" kernelrelease)"
rm -f "$SCRIPT_DIR/out/modules.vhdx"
sudo "$WORKDIR/Microsoft/scripts/gen_modules_vhdx.sh" "$MODULES_OUTDIR" "$KERNEL_RELEASE" "$SCRIPT_DIR/out/modules.vhdx"

echo "-- Built kernel bzImage and modules.vhdx into $SCRIPT_DIR/out"
