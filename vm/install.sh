#!/usr/bin/env bash
# Host setup for the win11 Looking Glass VM. Idempotent: run it again at any time.
# Usage: vm/install.sh <step>...
# Steps: packages groups shm image looking-glass define vfio all
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LG_VERSION="B7"
LG_MARKER="/usr/local/share/looking-glass/version"
GPU_ADDRESS="0000:03:00.0"
IMAGE_DIR="/var/lib/libvirt/images"
IMAGE="$IMAGE_DIR/win11.img"
IMAGE_SIZE="500G"
APPARMOR_FILE="/etc/apparmor.d/local/abstractions/libvirt-qemu"
APPARMOR_LINE="/dev/shm/looking-glass rw,"
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Copies $1 to $2 if the content is different. Returns 0 if it made a change.
install_file() {
    if sudo cmp -s "$1" "$2"; then
        echo "ok: $2"
        return 1
    fi
    sudo install -D -m 0644 "$1" "$2"
    echo "changed: $2"
}

step_packages() {
    sudo apt-get install -y \
        qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients \
        virt-manager virtinst ovmf swtpm swtpm-tools \
        binutils-dev cmake fonts-dejavu-core libfontconfig-dev gcc g++ pkg-config \
        libegl-dev libgl-dev libgles-dev libspice-protocol-dev nettle-dev \
        libx11-dev libxcursor-dev libxi-dev libxinerama-dev libxpresent-dev \
        libxss-dev libxkbcommon-dev libwayland-dev wayland-protocols \
        libpipewire-0.3-dev libpulse-dev libsamplerate0-dev curl
    echo "ok: packages installed"
}

step_groups() {
    local group
    for group in libvirt kvm; do
        if id -nG "$USER" | tr ' ' '\n' | grep -qx "$group"; then
            echo "ok: $USER is in $group"
        else
            sudo usermod -aG "$group" "$USER"
            echo "changed: added $USER to $group (log out and in again)"
        fi
    done
}

step_shm() {
    install_file "$here/etc/tmpfiles.d/10-looking-glass.conf" \
        /etc/tmpfiles.d/10-looking-glass.conf || true
    sudo systemd-tmpfiles --create /etc/tmpfiles.d/10-looking-glass.conf

    # The libvirt AppArmor profile on Debian blocks QEMU from the file without this line.
    if sudo grep -qxF "$APPARMOR_LINE" "$APPARMOR_FILE" 2>/dev/null; then
        echo "ok: $APPARMOR_FILE"
    else
        sudo mkdir -p "$(dirname "$APPARMOR_FILE")"
        echo "$APPARMOR_LINE" | sudo tee -a "$APPARMOR_FILE" >/dev/null
        sudo systemctl reload apparmor
        echo "changed: $APPARMOR_FILE"
    fi
}

step_image() {
    sudo mkdir -p "$IMAGE_DIR"
    # A raw image on copy-on-write btrfs fragments. New files inherit +C from the directory.
    if lsattr -d "$IMAGE_DIR" | cut -d' ' -f1 | grep -q C; then
        echo "ok: $IMAGE_DIR is nocow"
    else
        sudo chattr +C "$IMAGE_DIR"
        echo "changed: $IMAGE_DIR is nocow"
    fi
    if sudo test -e "$IMAGE"; then
        echo "ok: $IMAGE exists, not touched"
    else
        sudo qemu-img create -f raw "$IMAGE" "$IMAGE_SIZE"
        echo "changed: created $IMAGE"
    fi
}

step_looking_glass() {
    if [[ "$(cat "$LG_MARKER" 2>/dev/null)" == "$LG_VERSION" ]]; then
        echo "ok: looking-glass-client $LG_VERSION"
        return
    fi
    local build
    build="$(mktemp -d)"
    curl -fL "https://looking-glass.io/artifact/$LG_VERSION/source" -o "$build/source.tar.gz"
    tar -xzf "$build/source.tar.gz" -C "$build"
    cmake -S "$build/looking-glass-$LG_VERSION/client" -B "$build/out" -DCMAKE_BUILD_TYPE=Release
    cmake --build "$build/out" --parallel
    sudo cmake --install "$build/out"
    echo "$LG_VERSION" | sudo install -D -m 0644 /dev/stdin "$LG_MARKER"
    rm -rf "$build"
    echo "changed: installed looking-glass-client $LG_VERSION"
}

step_define() {
    sudo virsh net-autostart default >/dev/null
    sudo virsh net-list --name | grep -qx default || sudo virsh net-start default
    sudo virsh define "$here/win11.xml"
    echo "ok: domain win11 defined from $here/win11.xml"
}

# True if an amdgpu GPU other than the XTX has a connected display.
igpu_drives_display() {
    local dev status
    for dev in /sys/bus/pci/drivers/amdgpu/0000:*; do
        [[ -e "$dev" ]] || continue
        [[ "$(basename "$dev")" == "$GPU_ADDRESS" ]] && continue
        for status in "$dev"/drm/card*/card*-*/status; do
            [[ -e "$status" && "$(cat "$status")" == "connected" ]] && return 0
        done
    done
    return 1
}

step_vfio() {
    if ! igpu_drives_display; then
        echo "refused: no second amdgpu GPU with a connected display." >&2
        echo "Enable the iGPU in the BIOS and move the monitor cable to the" >&2
        echo "motherboard output first. See vm/README.md." >&2
        exit 1
    fi
    if install_file "$here/etc/modprobe.d/vfio.conf" /etc/modprobe.d/vfio.conf; then
        sudo update-initramfs -u
        echo "changed: initramfs rebuilt, reboot to bind the XTX to vfio-pci"
    fi
}

[[ $# -gt 0 ]] || { sed -n '2,4p' "${BASH_SOURCE[0]}"; exit 2; }

for step in "$@"; do
    case "$step" in
        packages)      step_packages ;;
        groups)        step_groups ;;
        shm)           step_shm ;;
        image)         step_image ;;
        looking-glass) step_looking_glass ;;
        define)        step_define ;;
        vfio)          step_vfio ;;
        all)           step_packages; step_groups; step_shm; step_image
                       step_looking_glass; step_define; step_vfio ;;
        *)             echo "unknown step: $step" >&2; exit 2 ;;
    esac
done
