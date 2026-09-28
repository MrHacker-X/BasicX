<div align="center">

# ⃤ &nbsp;B A S I C X&nbsp; ⃤

### *📦 One command. Fully loaded Termux. Zero guesswork.*

<br>

<img src="https://img.shields.io/github/stars/MrHacker-X/BasicX?style=for-the-badge&color=orange">
<img src="https://img.shields.io/github/forks/MrHacker-X/BasicX?style=for-the-badge&color=purple">
<img src="https://img.shields.io/github/issues/MrHacker-X/BasicX?style=for-the-badge&color=red">
<img src="https://img.shields.io/github/license/MrHacker-X/BasicX?style=for-the-badge&color=blue">

<br>

![Platform](https://img.shields.io/badge/Platform-Termux%20ONLY-2ea44f?style=flat-square&logo=android&logoColor=white)
![Language](https://img.shields.io/badge/Language-Pure%20Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Packages](https://img.shields.io/badge/Packages-40%2B-8A2BE2?style=flat-square)
![Keys](https://img.shields.io/badge/API%20Keys-NONE-success?style=flat-square)

[Why](#-why-basicx) · [Install](#-installation) · [What Gets Installed](#-what-gets-installed) · [FAQ](#-faq)

</div>

---

## 🎯 Why BasicX?

> Fresh Termux install is bare - no `git`, no `python`, no editors, no tools.
> **BasicX is the one command a beginner runs first**: it upgrades the base
> system, installs a curated 2025-ready package set, links your Android
> storage, and verifies everything worked.
>
> **Pure bash.** No python needed *before* the setup - the script works on a
> stock Termux, which is exactly what a first-time user has.
>
> **Termux-only by design** - it refuses to run anywhere else, with a clear message.

## 🖼 Preview

<div align="center">

![BasicX setup](https://i.ibb.co/nq7P75NL/Screenshot-20260929-024104-Termux.jpg)

</div>

## 🚀 Installation

Run this in **Termux** (F-Droid or GitHub build recommended over Play Store):

```bash
pkg update -y && pkg install git -y
git clone https://github.com/MrHacker-X/BasicX.git
cd BasicX
bash setup.sh
```

<details>
<summary><b>⚡ One-liner</b></summary>

```bash
pkg update -y && pkg install git -y && git clone https://github.com/MrHacker-X/BasicX.git && cd BasicX && bash setup.sh
```

</details>

<details>
<summary><b>🔍 What setup.sh actually does</b></summary>

- **Termux guard** - refuses non-Termux systems (macOS/Linux/Windows)
- **Auto repo-heal** - if the default mirror fails, switches to a working mirror automatically
- **`apt update`** with live output (never looks frozen)
- **Grouped installs** - essentials always; dev/power/network/repos by choice
  (or answer `Y` once for everything) - every package shown live as apt works
- **Per-package fallback** - one broken package never sinks the whole group
- **Storage, safely** - runs `termux-setup-storage` the normal way, then
  simply checks on disk whether it worked (the script can never get stuck
  waiting on the Android dialog)
- **Verification** - checks that `git/python/pip/node/ssh/...` actually work
- **Summary** - installed count + anything skipped

</details>

---

## 📦 What Gets Installed

| Group | Packages |
|---|---|
| 🧰 **Essentials** (always) | `git` `curl` `wget` `unzip` `zip` `tar` `unrar` `nano` `vim` `openssh` `openssl-tool` `termux-api` `termux-services` `python` `python-pip` `nodejs-lts` |
| 🛠 **Language toolchain** (optional) | `clang` `make` `binutils` `pkg-config` `golang` `rust` `openjdk-21` |
| ⚡ **Power tools** (optional) | `neovim` `micro` `tmux` `zsh` `fish` `htop` `fastfetch` `bat` `eza` `ripgrep` `fd` `jq` `tree` `ncurses-utils` |
| 🌐 **Network tools** (optional) | `nmap` `whois` `dnsutils` `socat` `traceroute` `findomain` `tor` |
| 🗄 **Extra repos** (optional) | `root-repo` `x11-repo` `tur-repo` |

<details>
<summary><b>🕐 Why the old package list had to change</b></summary>

The 6-year-old list installed packages that **no longer exist or are obsolete** in 2025:

| Old (removed) | Why | New (this repo) |
|---|---|---|
| `python2`, `python2-static`, `python2-six` | Python 2 EOL Jan 2020 - dropped from Termux | `python` (3.x) + `python-pip` |
| `python3` | merged into `python` | `python` |
| `dnsutils-static` | removed | `dnsutils` |
| `vim-python` | merged into `vim` | `vim` |
| `o-editor`, `ngrok`, `youtubedr` | removed from main repo | - (or via `npm`/pip if you need them) |
| `wireshark-gtk` | GTK variant dropped | - |
| `nodejs` | huge; LTS is the sane default | `nodejs-lts` |
| `openjdk-17` | superseded | `openjdk-21` |
| - | modern staples the old list missed | `bat` `eza` `ripgrep` `fd` `jq` `fastfetch` `tmux` `micro` |

All package names in `setup.sh` are verified against the live Termux `main`
repository (aarch64) as of 2025.

</details>

---

## ❓ FAQ

<details>
<summary><b>Can I run this on Linux/macOS?</b></summary>

No - BasicX hard-fails outside Termux. It's a Termux bootstrap script by
design; other systems have their own package managers.
</details>

<details>
<summary><b>It says "mirror failed" - what do I do?</b></summary>

The script auto-switches to a working mirror. If both fail, run
`termux-change-repo` manually, pick a nearby mirror, then re-run `setup.sh`.
</details>

<details>
<summary><b>Some packages were skipped - why?</b></summary>

A package can be unavailable for your architecture or temporarily broken.
The script installs the rest anyway and lists anything skipped in the summary.
Re-run `setup.sh` anytime - it's safe to repeat.
</details>

<details>
<summary><b>Do I need to reinstall after Termux updates?</b></summary>

No. Everything installs into the normal Termux prefix and updates with
`pkg upgrade`.
</details>

<details>
<summary><b>Storage permission popup didn't appear?</b></summary>

The script runs `termux-setup-storage` normally and then just checks whether
`~/storage` appeared - it never waits on the dialog. If nothing showed up,
grant it manually: run `termux-setup-storage` again, or open
**Android Settings → Apps → Termux → Permissions → Files** and allow
all files, then re-run the command.
</details>

---

## 🧰 Tech Stack

| Layer | Tech |
|---|---|
| 🖥 Installer | Pure POSIX-ish bash - no python, no curl-download shenanigans |
| 🎨 UI | Colored CLI output (auto-disabled when piped) |
| 🛡 Safety | `set -u`, Termux-only guard, per-package fallbacks, non-blocking storage step, zero self-deletion |

---

## ⚠️ Disclaimer

> BasicX only installs official Termux repository packages and links storage.
> Use responsibly. The developers hold no responsibility for misuse.

## 🤝 Contributing

Found a broken package name or want one added? Open an
[issue](https://github.com/MrHacker-X/BasicX/issues) or a pull request.

## 📜 License

Released under the [GNU GPL v3](LICENSE).

---

<div align="center">

**⃤ BasicX** - crafted with 📦🟢 by **[MrHacker-X](https://github.com/MrHacker-X)**

⭐ **Found it useful? Star the repo - it helps more than you know.** ⭐

</div>
