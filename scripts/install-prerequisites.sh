#!/usr/bin/env bash
#
# Installs the prerequisites for building the firmware with Zephyr on a fresh
# Ubuntu/Debian system (including WSL). Safe to re-run: existing parts are skipped.
#
# What is installed where, and why: doc/sw/toolchain.adoc, chapter "Installationsorte".
#
#   1. System packages (apt, needs sudo)
#   2. Python virtual environment with west in <workspace>/.venv
#   3. Zephyr SDK in ~/zephyr-sdk-<version> (user level, no sudo)
#
# Not part of this script: creating the Zephyr workspace (west init/update), which
# needs the west.yml of this repository, and usbipd-win on the Windows side (WSL).
#
# Usage: scripts/install-prerequisites.sh [--dry-run] [--skip-apt] [--skip-python] [--skip-sdk]
#
# Environment overrides:
#   ZEPHYR_WS               workspace root, holds .venv (default: ~/git/mischpult-workspace)
#   ZEPHYR_SDK_VERSION      SDK version (default: 1.0.1)
#   ZEPHYR_SDK_DIR          SDK install dir (default: ~/zephyr-sdk-<version>)
#   ZEPHYR_SDK_TOOLCHAINS   space separated GNU toolchains (default: xtensa-espressif_esp32s3_zephyr-elf)
#   WEST_VERSION            pin west to this version (default: latest)

set -euo pipefail

: "${ZEPHYR_WS:=$HOME/git/mischpult-workspace}"
: "${ZEPHYR_SDK_VERSION:=1.0.1}"
: "${ZEPHYR_SDK_DIR:=$HOME/zephyr-sdk-${ZEPHYR_SDK_VERSION}}"
: "${ZEPHYR_SDK_TOOLCHAINS:=xtensa-espressif_esp32s3_zephyr-elf}"
: "${WEST_VERSION:=}"

readonly SDK_BASE_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}"
readonly MIN_CMAKE="3.28.0"
readonly MIN_PYTHON="3.12"
readonly MIN_DTC="1.4.6"

# Package list from the Zephyr Getting Started Guide (Ubuntu), plus curl,
# ca-certificates (downloads) and clang-format (code style, see AGENTS.md).
APT_PACKAGES=(
  git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget
  python3-dev python3-venv python3-tk xz-utils file make gcc gcc-multilib
  g++-multilib libsdl2-dev libmagic1 curl ca-certificates clang-format
)

DRY_RUN=0
DO_APT=1
DO_PYTHON=1
DO_SDK=1
tmp=""

log() { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Runs a command, or only prints it in dry-run mode.
run() {
  if (( DRY_RUN )); then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

# True if version $1 is greater than or equal to version $2.
version_ge() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

usage() {
  sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'
}

parse_args() {
  while (( $# )); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --skip-apt) DO_APT=0 ;;
      --skip-python) DO_PYTHON=0 ;;
      --skip-sdk) DO_SDK=0 ;;
      -h|--help) usage; exit 0 ;;
      *) usage >&2; die "unknown argument: $1" ;;
    esac
    shift
  done
}

check_platform() {
  [[ "$(uname -s)" == "Linux" ]] || die "Linux only (WSL counts as Linux)"
  if (( DO_APT )); then
    command -v apt-get >/dev/null || die "apt-get not found, Ubuntu/Debian only"
  fi
  if (( DO_SDK )); then
    [[ "$(uname -m)" == "x86_64" ]] || die "SDK step supports x86_64 only (aarch64 not checked)"
  fi
  if grep -qi microsoft /proc/version 2>/dev/null; then
    log "WSL detected"
    case "$ZEPHYR_WS$ZEPHYR_SDK_DIR" in
      */mnt/*) die "workspace and SDK must be on the Linux file system, not under /mnt (slow, wrong file permissions)" ;;
    esac
  fi
}

install_apt() {
  log "System packages (apt)"
  local sudo_cmd=()
  if (( EUID != 0 )); then
    command -v sudo >/dev/null || die "sudo not found and not running as root"
    sudo_cmd=(sudo)
  fi
  local packages=() package
  for package in "${APT_PACKAGES[@]}"; do
    # gcc-multilib is not available on AArch64 (see Zephyr Getting Started Guide)
    if [[ "$(dpkg --print-architecture)" == "arm64" && "$package" == *-multilib ]]; then
      continue
    fi
    packages+=("$package")
  done
  run "${sudo_cmd[@]}" apt-get update
  run "${sudo_cmd[@]}" apt-get install -y --no-install-recommends "${packages[@]}"
}

# Checks one tool against its minimum version. In dry-run mode a missing tool is only reported.
check_version() {
  local name="$1" minimum="$2" actual="$3"
  if [[ -z "$actual" ]]; then
    if (( DRY_RUN )); then warn "$name not installed yet"; return 0; fi
    die "$name not found"
  fi
  version_ge "$actual" "$minimum" || die "$name $actual found, at least $minimum required"
  log "$name $actual (minimum $minimum)"
}

check_versions() {
  log "Checking minimum versions"
  local cmake_v="" python_v="" dtc_v=""
  command -v cmake >/dev/null && cmake_v="$(cmake --version | awk 'NR==1 {print $3}')"
  command -v python3 >/dev/null && python_v="$(python3 -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])')"
  command -v dtc >/dev/null && dtc_v="$(dtc --version | awk '{print $NF}')"
  check_version cmake "$MIN_CMAKE" "$cmake_v"
  check_version python3 "$MIN_PYTHON" "$python_v"
  check_version dtc "$MIN_DTC" "$dtc_v"
}

install_python() {
  log "Python virtual environment in $ZEPHYR_WS/.venv"
  local venv="$ZEPHYR_WS/.venv"
  run mkdir -p "$ZEPHYR_WS"
  if [[ ! -x "$venv/bin/python" ]]; then
    run python3 -m venv "$venv"
  fi
  run "$venv/bin/python" -m pip install --upgrade pip
  run "$venv/bin/python" -m pip install "west${WEST_VERSION:+==$WEST_VERSION}"
}

# Downloads an SDK release asset and verifies its SHA-256 against the release's sha256.sum.
fetch_verified() {
  local archive="$1" dir="$2"
  run curl -fsSL --retry 3 -o "$dir/$archive" "$SDK_BASE_URL/$archive"
  if (( DRY_RUN )); then
    printf '[dry-run] verify sha256 of %s\n' "$archive"
  else
    (cd "$dir" && grep -E "  ${archive}\$" sha256.sum | sha256sum -c -)
  fi
}

install_sdk() {
  log "Zephyr SDK $ZEPHYR_SDK_VERSION in $ZEPHYR_SDK_DIR"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  local changed=0

  run curl -fsSL --retry 3 -o "$tmp/sha256.sum" "$SDK_BASE_URL/sha256.sum"

  if [[ -f "$ZEPHYR_SDK_DIR/sdk_version" ]]; then
    local installed
    installed="$(<"$ZEPHYR_SDK_DIR/sdk_version")"
    [[ "$installed" == "$ZEPHYR_SDK_VERSION" ]] \
      || die "$ZEPHYR_SDK_DIR contains SDK $installed, expected $ZEPHYR_SDK_VERSION"
    log "SDK base already installed, skipping"
  else
    local base="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64_minimal.tar.xz"
    fetch_verified "$base" "$tmp"
    run tar -xf "$tmp/$base" -C "$tmp"
    run mkdir -p "$(dirname "$ZEPHYR_SDK_DIR")"
    run mv "$tmp/zephyr-sdk-${ZEPHYR_SDK_VERSION}" "$ZEPHYR_SDK_DIR"
    changed=1
  fi

  local toolchain
  for toolchain in $ZEPHYR_SDK_TOOLCHAINS; do
    if [[ -d "$ZEPHYR_SDK_DIR/gnu/$toolchain" ]]; then
      log "Toolchain $toolchain already installed, skipping"
      continue
    fi
    local archive="toolchain_gnu_linux-x86_64_${toolchain}.tar.xz"
    fetch_verified "$archive" "$tmp"
    run mkdir -p "$ZEPHYR_SDK_DIR/gnu"
    run tar -xf "$tmp/$archive" -C "$ZEPHYR_SDK_DIR/gnu"
    changed=1
  done

  # setup.sh installs the host tools and registers the SDK as CMake package, so that
  # Zephyr finds it. It is run once, and again whenever something was added.
  if (( changed )) || [[ ! -f "$ZEPHYR_SDK_DIR/.setup-done" ]]; then
    run bash -c 'cd "$1" && ./setup.sh -h -c' _ "$ZEPHYR_SDK_DIR"
    run touch "$ZEPHYR_SDK_DIR/.setup-done"
  fi
}

print_next_steps() {
  log "Done"
  cat <<EOF

Next steps:
  source "$ZEPHYR_WS/.venv/bin/activate"
  Create the Zephyr workspace (needs west.yml in this repository), see doc/sw/toolchain.adoc.
  WSL only: install usbipd-win on the Windows side to flash the board.
EOF
}

main() {
  parse_args "$@"
  check_platform
  (( DO_APT )) && install_apt
  check_versions
  (( DO_PYTHON )) && install_python
  (( DO_SDK )) && install_sdk
  print_next_steps
}

main "$@"
