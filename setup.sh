#!/data/data/com.termux/files/usr/bin/env bash
# github.com/MrHacker-X
# BasicX - professional first-time Termux setup.

set -u

# ---------- colors ----------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    RD=$'\e[31m'; GR=$'\e[32m'; YL=$'\e[33m'; CY=$'\e[36m'; BW=$'\e[1m'; DM=$'\e[2m'; XX=$'\e[0m'
else
    RD=""; GR=""; YL=""; CY=""; BW=""; DM=""; XX=""
fi

info() { printf '%s[*]%s %s\n' "$CY" "$XX" "$1"; }
ok()   { printf '%s[+]%s %s\n' "$GR" "$XX" "$1"; }
warn() { printf '%s[!]%s %s\n' "$YL" "$XX" "$1"; }
err()  { printf '%s[x]%s %s\n' "$RD" "$XX" "$1" >&2; }
fail() { err "$1"; exit 1; }

# ---------- Termux-only guard ----------
[ -n "${TERMUX_VERSION:-}" ] || fail "This is not Termux. BasicX runs ONLY inside Termux."
case "$HOME" in
    /data/data/com.termux*) ;;
    *) fail "Termux env detected but \$HOME is not the Termux prefix. Run it inside Termux." ;;
esac
command -v apt >/dev/null 2>&1 || fail "apt not found - is this a real Termux install?"

WH=$'\e[1;97m'
clear
printf '%s\n' "${WH} ██████╗  █████╗ ███████╗██╗ ██████╗${YL}██╗  ██╗${XX}"
printf '%s\n' "${WH} ██╔══██╗██╔══██╗██╔════╝██║██╔════╝${YL}╚██╗██╔╝${XX}"
printf '%s\n' "${WH} ██████╔╝███████║███████╗██║██║     ${YL} ╚███╔╝${XX}"
printf '%s\n' "${WH} ██╔══██╗██╔══██║╚════██║██║██║     ${YL} ██╔██╗${XX}"
printf '%s\n' "${WH} ██████╔╝██║  ██║███████║██║╚██████╗${YL}██╔╝ ██╗${XX}"
printf '%s\n' "${WH} ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝${YL}╚═╝  ╚═╝${XX}"
printf '%s\n' "${YL}          first-time ${BW}Termux${XX}${YL} setup · ${BW}MrHacker-X${XX}"
echo

# ---------- interactive menu ----------
ESSENTIALS="git curl wget unzip zip tar unrar nano vim openssh openssl-tool termux-api termux-services python python-pip nodejs-lts"
DEV="clang make binutils pkg-config golang rust openjdk-21"
POWER="neovim micro tmux zsh fish htop fastfetch bat eza ripgrep fd jq tree ncurses-utils"
NETWORK="nmap whois dnsutils socat traceroute findomain tor"
REPOS="root-repo x11-repo tur-repo"

choose() {
    printf '%s[?]%s %s[y/N]%s ' "$CY" "$XX" "$1" "$XX"
    read -r ans
    [ "$ans" = "y" ] || [ "$ans" = "Y" ]
}

printf '%s[?]%s Install ALL recommended packages (essentials + dev + power + network)? %s[Y/n]%s ' "$CY" "$XX" "$BW" "$XX"
read -r do_all
[ "$do_all" = "n" ] || [ "$do_all" = "N" ] && do_all="n" || do_all="y"

if [ "$do_all" = "n" ]; then
    choose "Add language toolchain (clang/make/golang/rust/Java)?" && DEV_PICK=1 || DEV_PICK=0
    choose "Add power-user tools (neovim/tmux/zsh/bat/jq/...)?" && POWER_PICK=1 || POWER_PICK=0
    choose "Add network tools (nmap/whois/dnsutils/tor/...)?" && NET_PICK=1 || NET_PICK=0
    choose "Add extra repos (root-repo/x11-repo/tur-repo)?" && REPO_PICK=1 || REPO_PICK=0
else
    DEV_PICK=1; POWER_PICK=1; NET_PICK=1; REPO_PICK=1
fi

# ---------- apt update (with mirror auto-heal) ----------
info "Refreshing package lists (live apt output below)..."
echo "${DM}──────────────────────── apt output ────────────────────────${XX}"
if ! apt update -y; then
    echo "${DM}────────────────────────────────────────────────────────────${XX}"
    warn "Default mirror failed — switching to mirror.mwt.me ..."
    sed -i 's|^\deb.*packages.termux.dev.*|deb https://mirror.mwt.me/termux/main stable main|' "$PREFIX/etc/apt/sources.list" 2>/dev/null
    grep -q "mirror.mwt.me" "$PREFIX/etc/apt/sources.list" 2>/dev/null \
        && ok "Mirror switched." \
        || warn "Auto-mirror switch failed — check your connection."
    echo "${DM}──────────────────────── apt output ────────────────────────${XX}"
    if ! apt update -y; then
        echo "${DM}────────────────────────────────────────────────────────────${XX}"
        fail "apt update still failing. Run 'termux-change-repo' manually."
    fi
fi
echo "${DM}────────────────────────────────────────────────────────────${XX}"
ok "Package lists ready."

# ---------- spinner (kept running by a background process) ----------
SPIN_PID=""
spin_start() {
    [ -t 1 ] || return 0
    (
        spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        i=0
        while :; do
            i=$(( (i + 1) % 10 ))
            printf '\r%s[%s]%s %s' "$CY" "${spin:$i:1}" "$XX" "$1"
            sleep 0.1
        done
    ) &
    SPIN_PID=$!
}

spin_stop() {
    [ -n "$SPIN_PID" ] || return 0
    kill "$SPIN_PID" 2>/dev/null
    wait "$SPIN_PID" 2>/dev/null
    printf '\r\033[K'
    SPIN_PID=""
}

trap 'spin_stop' EXIT

# ---------- install helper (verifies each package) ----------
PKGS_INSTALLED=0
PKGS_FAILED=""

install_group() {
    local title="$1"; shift
    [ "$#" -eq 0 ] && return 0
    info "Installing ${title} ($# packages)"
    info "Following apt output is live — downloads can take a while."
    echo "${DM}──────────────────────── apt output ────────────────────────${XX}"

    if apt install -y "$@"; then
        echo "${DM}────────────────────────────────────────────────────────────${XX}"
        ok "${title} done."
        PKGS_INSTALLED=$((PKGS_INSTALLED + $#))
        return 0
    fi

    # fallback: install one-by-one so one bad package doesn't sink the group
    echo "${DM}────────────── retrying one-by-one (a package failed) ───────────────${XX}"
    local p
    for p in "$@"; do
        echo "${CY}[*]${XX} $p ..."
        if apt install -y "$p"; then
            PKGS_INSTALLED=$((PKGS_INSTALLED + 1))
        else
            err "Could not install: $p"
            PKGS_FAILED="$PKGS_FAILED $p"
        fi
    done
    echo "${DM}────────────────────────────────────────────────────────────${XX}"
    ok "${title} finished."
}

install_group "essentials (git, python, node, ssh, ...)" $ESSENTIALS
[ "$DEV_PICK"  -eq 1 ] && install_group "language toolchain"            $DEV
[ "$POWER_PICK" -eq 1 ] && install_group "power-user tools"             $POWER
[ "$NET_PICK"  -eq 1 ] && install_group "network tools"                 $NETWORK
[ "$REPO_PICK" -eq 1 ] && install_group "extra repos"                   $REPOS

# ---------- storage: bare command, then verify on disk ----------
# Run the command with NO redirects and NO backgrounding — that is what makes
# the Android dialog appear. Afterwards we simply check if ~/storage exists.
echo
info "Requesting storage permission — accept the popup..."
termux-setup-storage

info "Checking if permission was granted..."
granted=0
for i in 1 2 3 4 5; do
    if [ -d "$HOME/storage/shared" ] || [ -d "$HOME/storage/dcim" ]; then
        granted=1
        break
    fi
    sleep 1
done

if [ "$granted" -eq 1 ]; then
    ok "Storage linked at ~/storage"
else
    warn "Storage not linked — run 'termux-setup-storage' later."
fi

# ---------- verify ----------
echo
info "Verifying installation..."
MISS=""
for c in git curl wget python pip node nano vim ssh unzip; do
    command -v "$c" >/dev/null 2>&1 || MISS="$MISS $c"
done
[ -z "$MISS" ] && ok "All essential commands verified." \
    || warn "Not found:$MISS (re-run setup.sh to retry, or install manually)"

# ---------- summary ----------
echo
echo
printf '%s\n' "${RD}<==============================================>${XX}"
printf '%s\n' "${GR}  BasicX setup complete${XX}"
printf '%s\n' "${BW}  $PKGS_INSTALLED packages installed${XX}"
[ -n "$PKGS_FAILED" ] && printf '%s\n' "${YL}  skipped:${XX} $PKGS_FAILED"
printf '%s\n' "${RD}<==============================================>${XX}"
printf '%s\n' "${DM}          created by MrHacker-X${XX}"
printf '%s\n' "${RD}<==============================================>${XX}"
echo
info "If tools are missing after reopening Termux, run: bash setup.sh"
echo
