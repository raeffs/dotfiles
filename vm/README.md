# win11 VM with Looking Glass

Windows 11 VM for Lightroom Classic. The RX 7900 XTX belongs to the VM, the
iGPU runs the desktop. Design: `docs/superpowers/specs/2026-09-18-windows-vm-looking-glass-design.md`.

## Daily use

`SUPER + ALT + L` starts the VM and opens Looking Glass. The escape key is
Right Ctrl. The keyboard must have a key that sends Right Ctrl.

| Keys | Effect |
|---|---|
| Hold Right Ctrl | Shows the list of hotkeys |
| Tap Right Ctrl | Locks the mouse into the VM, or releases it |
| Right Ctrl + `F` | Fullscreen on or off |
| Right Ctrl + `Q` | Quits the client. The VM continues to run |

Shut Windows down from its start menu. Do not force the VM off: see
"Card off the bus" below.

Nothing is connected to the XTX. When the card has no monitor, the AMD driver
makes a virtual display (`AMD vDisplay`, 3840x2160 at 60 Hz), and Looking
Glass captures it. If a driver update removes the virtual display, put an HDMI
dummy plug (3840x2160) in the XTX. That was tested and works, also when the
plug is attached at VM boot.

## Hardware

1. BIOS: integrated graphics `Force`, primary display `IGFX`, SVM and IOMMU on.
2. Monitor to the motherboard output.
3. Nothing on the outputs of the XTX. An HDMI dummy plug is the fallback, see
   "Daily use".

## Setup on a new install

1. `make` in the repo root.
2. `vm/install.sh check-packages` needs no root and shows if apt can install
   the packages. Then `vm/install.sh all`. The `vfio` step refuses to run
   until a display is connected to the iGPU.
3. Power the PC off and on.
4. Check: `lspci -k -s 03:00` shows `vfio-pci` two times, and
   `cat /sys/module/vfio_pci/parameters/disable_idle_d3` shows `Y`.
5. Put `win11.iso` and `virtio-win.iso` in `/var/lib/libvirt/images/iso/`.
6. All libvirt commands name `qemu:///system`. Without it a normal user talks
   to the session daemon, and `virsh define` makes a useless second domain.
   Put the domain in install mode:
   ```bash
   virt-xml -c qemu:///system win11 --remove-device --hostdev all
   virt-xml -c qemu:///system win11 --edit --video clearxml=yes,model=vga
   virt-xml -c qemu:///system win11 --add-device --disk /var/lib/libvirt/images/iso/win11.iso,device=cdrom,bus=sata,boot.order=2
   virt-xml -c qemu:///system win11 --add-device --disk /var/lib/libvirt/images/iso/virtio-win.iso,device=cdrom,bus=sata
   ```
7. Install Windows in the virt-manager console. Storage driver
   `viostor\w11\amd64`, network driver `NetKVM\w11\amd64`, then
   `virtio-win-guest-tools.exe`. Shut Windows down.
8. Attach the XTX and keep a console:
   ```bash
   virsh -c qemu:///system define vm/win11.xml
   virt-xml -c qemu:///system win11 --edit --video clearxml=yes,model=vga
   ```
9. Start the VM. Install AMD Adrenalin, then the Looking Glass host **B7**.
   Set the `AMD vDisplay` display to 3840x2160, 60 Hz, main display.
10. Press `SUPER + ALT + L` and check that Looking Glass shows the desktop of
    the `AMD vDisplay`, not the 1280x800 console. Do this before step 11:
    after it there is no console.
11. Shut Windows down. `virsh -c qemu:///system define vm/win11.xml` gives the
    final state.

`virsh -c qemu:///system define vm/win11.xml` always restores the final
state. It keeps the disk, the NVRAM and the TPM.

## Why the configuration is as it is

Each of these cost a debug session. Do not remove them.

- **`vga`, not `qxl`, as the temporary display.** With this OVMF and QEMU the
  firmware never initialises a QXL display. The console stays black.
- **`<rom bar='off'/>` on the XTX.** With the option ROM visible, OVMF
  initialises the outputs of the card when a display is attached at VM boot.
  The Windows driver then fails on that output: a garbled picture, then
  Code 43. An HDMI dummy plug that was plugged in after Windows had started
  worked, and that is how this was found.
- **`disable_idle_d3=1` for `vfio-pci`.** Without it the unused card goes to
  D3cold and does not wake: `Unable to change power state from D3cold to D0,
  device inaccessible`.
- **Disk by PCI address or `/dev/disk/by-id`.** The kernel names `nvme0n1` and
  `nvme1n1` swapped when the iGPU was enabled.

## Card off the bus

Symptom: the VM does not start, libvirt shows
`Unknown PCI header type '127' for device '0000:03:00.0'`, and
`lspci -x -s 03:00.0` shows only `ff`.

Cause: the reset at VM shutdown. The card survives it when the Windows driver
is healthy. It does not survive it after a guest crash or Code 43.

Fix: power the PC fully off, wait 10 seconds, power on. A reboot is not
sufficient.

## Looking Glass shows nothing

The VM has no emulated display, so there is no console when the Looking Glass
host or the virtual display fails.

1. `virsh -c qemu:///system shutdown win11`. This is an ACPI shutdown,
   Windows needs about 10 seconds. Wait until
   `virsh -c qemu:///system domstate win11` prints `shut off`. Do not use
   `destroy`.
2. `virt-xml -c qemu:///system win11 --edit --video clearxml=yes,model=vga`.
3. Start the VM and use the console in virt-manager. If the AMD virtual
   display is gone, put the HDMI dummy plug in the XTX.
4. When it works again, shut Windows down and run
   `virsh -c qemu:///system define vm/win11.xml`.

## Rules

- The Looking Glass client and host versions must be the same. To upgrade,
  change `LG_VERSION` in `install.sh`, run `vm/install.sh looking-glass`, and
  install the same host version in Windows.
- Do not set `icc` or `cm` for the monitor in Hyprland. Install the ICC profile
  of the monitor in Windows.

## Specific to this machine

These values are tied to this host and this install. Re-check them after a
hardware or BIOS change.

- The user name `raphael` in `etc/tmpfiles.d/10-looking-glass.conf`.
- PCI addresses `03:00.0` (XTX) and `07:00.0` (990 PRO). Check
  `lspci -nn -s 03:00` after a BIOS or hardware change.
- The CPU numbers in `win11.xml`: on the 9950X, CCD 1 is cores 8-15 and
  24-31.
- The MAC address and the machine type in `win11.xml`.
- `/var/lib/libvirt` must be on btrfs (`chattr +C`).
- `stow` and `make` must be installed before setup step 1.
- `libxkbcommon-dev` is requested at the version of the installed
  `libxkbcommon0`, because the library came from backports. If
  `check-packages` fails for another `-dev` package, the same cause applies.
- Downloads: Windows 11 ISO
  <https://www.microsoft.com/software-download/windows11>, virtio-win ISO
  <https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso>,
  Looking Glass host <https://looking-glass.io/downloads>.

## Not done

- Direct output of the XTX to the monitor. The cause is not known. With a
  working direct output, monitor input 2 would give a direct 10-bit picture.
  - HDMI cable: the monitor reported no source, Windows saw no monitor.
  - DisplayPort cable before `<rom bar='off'/>`: the firmware picture, then a
    garbled picture, then no signal. Windows showed Code 43 for the XTX.
  - DisplayPort cable after it, plugged in while Windows ran: the driver stays
    healthy, but Windows does not detect the monitor.
- The `kvmfr` kernel module.

## Move to the 990 PRO

In `win11.xml`, replace the `<disk>` element with a `<hostdev>` for
`0000:07:00.0` and add `1` as its boot order. Add the NVMe device ID to
`vfio.conf`.

The 990 PRO is `144d:a80c`. The Linux disk (9100 PRO) is `144d:a810`. Binding
by ID takes every device with that ID, so check `lspci -nn` first: if both
SSDs had the same ID, vfio-pci would take the root disk too.

## Rollback

```bash
sudo rm /etc/modprobe.d/vfio.conf
sudo update-initramfs -u
```

Move the monitor cable back to the XTX and power the PC off and on.

Undefine the VM or do not press `SUPER + ALT + L`: the launcher refuses to
start the VM while the XTX is not on `vfio-pci`, but virt-manager does not.

If there is no picture after the `vfio` step: the XTX no longer shows the
desktop. Connect the monitor to the motherboard output and check that the
BIOS has the integrated graphics on.
