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

The HDMI dummy plug stays in the HDMI port of the XTX. Without a display on
the card, Windows has no desktop for Looking Glass to capture.

## Hardware

1. BIOS: integrated graphics `Force`, primary display `IGFX`, SVM and IOMMU on.
2. Monitor to the motherboard output.
3. HDMI dummy plug (3840x2160) in the HDMI port of the XTX.

## Setup on a new install

1. `make` in the repo root.
2. `vm/install.sh check-packages` needs no root and shows if apt can install
   the packages. Then `vm/install.sh all`. The `vfio` step refuses to run
   until a display is connected to the iGPU.
3. Log out and in, then power the PC off and on.
4. Check: `lspci -k -s 03:00` shows `vfio-pci` two times, and
   `cat /sys/module/vfio_pci/parameters/disable_idle_d3` shows `Y`.
5. Put `win11.iso` and `virtio-win.iso` in `/var/lib/libvirt/images/iso/`.
6. Put the domain in install mode:
   ```bash
   export LIBVIRT_DEFAULT_URI=qemu:///system
   virt-xml win11 --remove-device --hostdev all
   virt-xml win11 --edit --video clearxml=yes,model=vga
   virt-xml win11 --add-device --disk /var/lib/libvirt/images/iso/win11.iso,device=cdrom,bus=sata,boot.order=2
   virt-xml win11 --add-device --disk /var/lib/libvirt/images/iso/virtio-win.iso,device=cdrom,bus=sata
   ```
7. Install Windows in the virt-manager console. Storage driver
   `viostor\w11\amd64`, network driver `NetKVM\w11\amd64`, then
   `virtio-win-guest-tools.exe`. Shut Windows down.
8. Attach the XTX and keep a console:
   ```bash
   virsh define vm/win11.xml
   virt-xml win11 --edit --video clearxml=yes,model=vga
   ```
9. Start the VM. Install AMD Adrenalin, then the Looking Glass host **B7**.
   Set the display of the dummy plug to 3840x2160, 60 Hz, main display.
10. Shut Windows down. `virsh define vm/win11.xml` gives the final state.

`virsh define vm/win11.xml` always restores the final state. It keeps the
disk, the NVRAM and the TPM.

## Why the configuration is as it is

Each of these cost a debug session. Do not remove them.

- **`vga`, not `qxl`, as the temporary display.** With this OVMF and QEMU the
  firmware never initialises a QXL display. The console stays black.
- **`<rom bar='off'/>` on the XTX.** With the option ROM visible, OVMF
  initialises the outputs of the card when a display is attached at VM boot.
  The Windows driver then fails on that output: a garbled picture, then
  Code 43. A display that is plugged in after Windows has started works, and
  that is how this was found.
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

## Rules

- The Looking Glass client and host versions must be the same. To upgrade,
  change `LG_VERSION` in `install.sh`, run `vm/install.sh looking-glass`, and
  install the same host version in Windows.
- Do not set `icc` or `cm` for the monitor in Hyprland. Install the ICC profile
  of the monitor in Windows.

## Not done

- Direct output of the XTX to the monitor. A DisplayPort cable showed a garbled
  picture and then no signal. That was before `<rom bar='off'/>`. It was not
  tested again. With it, monitor input 2 would give a direct 10-bit picture.
- The `kvmfr` kernel module.

## Move to the 990 PRO

In `win11.xml`, replace the `<disk>` element with a `<hostdev>` for
`0000:07:00.0` and add `1` as its boot order. Add the NVMe device ID to
`vfio.conf`.

## Rollback

```bash
sudo rm /etc/modprobe.d/vfio.conf
sudo update-initramfs -u
```

Move the monitor cable back to the XTX and power the PC off and on.
