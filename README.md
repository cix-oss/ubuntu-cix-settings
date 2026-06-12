# ubuntu-cix-settings

Debian source package providing default system settings for Ubuntu on **CIX P1** (Sky1 / Orion O6) ARM64 machines.

## Packages

This source builds two binary packages:

### `ubuntu-cix-p1-settings`

Core platform configuration applied to all CIX P1 devices:

- Kernel command-line parameters (ACPI, clock, reserved memory regions)
- Initramfs module lists for display drivers (`linlon_dp`, `trilin_dpsub`, `pwm_sky1`, `pinctrl_sky1`, `pinctrl_sky1_base`)
- Dracut configuration mirroring the initramfs-tools module list

### `ubuntu-cix-p1-settings-oem`

OEM-specific configuration including:

- Additional kernel parameters (`iomem=relaxed`, `simpledrm` disabled, `armchina_npu` blacklisted)
- Modprobe blacklists (`panthor`, `optee`, `snd-soc-sky1-card`, `snd-hda-cix-ipbloq`, `snd_soc_cdns_i2s_mc`)
- Environment override disabling Vulkan in GTK applications (`GDK_VULKAN_DISABLE=all`)
- systemd sleep configuration disabling all sleep states (suspend, hibernate, hybrid-sleep, suspend-then-hibernate)
- PCIe ASPM policy management service and system-sleep hook
- Bluetooth battery plugin enabled via `bluetoothd` drop-in
- **`bluetooth-autoconnect`** — a Python 3 / D-Bus / GLib daemon that auto-connects trusted Bluetooth devices on adapter power-on, device disconnect, and system wake, with debouncing and retry logic

## Requirements

- Ubuntu 26.04 (resolute) or compatible
- `arm64` architecture
- `debhelper-compat (= 13)` for building

### Runtime dependencies

**`ubuntu-cix-p1-settings`:**
- `cix-vpu-firmware`

**`ubuntu-cix-p1-settings-oem`:**
- `bluez`
- `python3`, `python3-dbus`, `python3-gi`
- `systemd`

## Building

```bash
dpkg-buildpackage -us -uc -b
```

The package contains only configuration files and a Python script — there is no upstream build step.

## Installation

```bash
sudo dpkg -i ../ubuntu-cix-p1-settings_*.deb
sudo dpkg -i ../ubuntu-cix-p1-settings-oem_*.deb
```

After installing the core package, `update-grub` is run automatically by the post-install script to apply kernel command-line changes.

## Project Structure

```
ubuntu-cix-settings/
├── bluetooth-autoconnect/   # Python daemon and systemd service units
├── debian/                  # Debian packaging metadata
├── dracut/                  # Dracut initramfs config
├── environment.d/           # systemd environment.d overrides
├── grub.d/                  # GRUB kernel cmdline (core)
├── grub.d-oem/              # GRUB kernel cmdline (OEM)
├── initramfs-tools/         # initramfs-tools module lists
├── modprobe.d/              # Driver blacklists
├── sleep.conf.d/            # systemd sleep state configuration
├── system-sleep/            # systemd-sleep hook scripts
└── systemd/                 # systemd unit files and drop-ins
```

## bluetooth-autoconnect

`bluetooth-autoconnect` is a Python 3 daemon that connects to trusted Bluetooth devices automatically. It supports two modes:

- **One-shot** (default): scans all powered adapters and attempts to connect to trusted devices, then exits.
- **Daemon** (`-d` / `--daemon`): monitors adapter power-on events, device disconnects, and system sleep/wake via D-Bus signals.

Device connection priority: **HID** (mouse, keyboard) → **Audio** (A2DP, HSP, HFP) → **Phone** → **Other**.

Key features:
- Debounced reconnection (1.5 s) when multiple devices disconnect simultaneously
- Adapter power-on debounce (3 s) to coalesce rapid power events
- Sleep/wake protection window (8 s) to ignore spurious disconnects during resume
- Boot-time fallback scans at 3 s, 6 s, and 10 s to handle missed adapter signals
- Exponential-backoff retry (up to 3 attempts) for failed connections

### Usage

```bash
# One-shot: connect trusted devices and exit
bluetooth-autoconnect

# Daemon mode with verbose logging
bluetooth-autoconnect -d -v
```

## Contributing

Contributions are welcome. Please open an issue or pull request at [github.com/cix-oss/ubuntu-cix-settings](https://github.com/cix-oss/ubuntu-cix-settings).

When submitting changes:

- Follow the existing code style and directory layout.
- Update `debian/changelog` with a new entry for any user-visible change.
- Ensure maintainer scripts use `command -v` for binary checks and avoid hard failures (`|| true`).

## License

This project is licensed under the **GNU General Public License v2.0 or later** (GPL-2+). See [`LICENSE`](LICENSE) for the full text.

