#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/microsoft/WSL2-Linux-Kernel.git"
BRANCH="linux-msft-wsl-6.18.y"
WORKDIR="/var/tmp/wsl-kernel"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$WORKDIR/.git" || "$(git -C "$WORKDIR" rev-parse --abbrev-ref HEAD)" != "$BRANCH" ]]; then
  echo "-- Cloning WSL kernel repo, branch $BRANCH"
  rm -rf "$WORKDIR"
  git clone "$REPO" "$WORKDIR" --depth 1 -b "$BRANCH"
else
  echo "-- Fetching latest changes"
  git -C "$WORKDIR" fetch --depth 1 origin "$BRANCH"
  git -C "$WORKDIR" reset --hard FETCH_HEAD
fi

echo "-- Copying config and applying changes"
cp "$WORKDIR/Microsoft/config-wsl" "$WORKDIR/.config"
cat "$SCRIPT_DIR/config-changes.config" >> "$WORKDIR/.config"
make -C "$WORKDIR" -s olddefconfig

echo "-- Building kernel image"
make -C "$WORKDIR" -j$(nproc) -s
mkdir -p "$SCRIPT_DIR/out"
cp "$WORKDIR/arch/x86/boot/bzImage" "$SCRIPT_DIR/out/bzImage"

echo "-- Building kernel modules and artifacts"
ARTIFACTS_DIR="${WORKDIR}/artifacts"
rm -rf "$ARTIFACTS_DIR"
make -C "$WORKDIR" -j"$(nproc)" -s modules
make -C "$WORKDIR" -j"$(nproc)" -s INSTALL_MOD_PATH="$ARTIFACTS_DIR/modules" modules_install
make -C "$WORKDIR" -j"$(nproc)" -s INSTALL_HDR_PATH="$ARTIFACTS_DIR/headers" headers_install
make -C "$WORKDIR/tools/perf" -j"$(nproc)" -s NO_JEVENTS=1 NO_JVMTI=1 NO_LIBTRACEEVENT=1 install DESTDIR="$ARTIFACTS_DIR/perf" prefix=/

echo "-- Generating modules.vhdx"
KERNEL_RELEASE="$(make -s -C "$WORKDIR" kernelrelease)"
rm -f "$SCRIPT_DIR/out/modules.vhdx"
# New layout requires WSL 2.9.8 or newer
"$WORKDIR/Microsoft/scripts/gen_artifacts_vhdx.sh" \
  "$ARTIFACTS_DIR/modules" "$ARTIFACTS_DIR/headers" "$ARTIFACTS_DIR/perf" \
  "$KERNEL_RELEASE" "$SCRIPT_DIR/out/modules.vhdx"

echo "-- Built kernel bzImage and modules.vhdx into $SCRIPT_DIR/out"
