#!/usr/bin/env bash
# Build Lightcoin Core on Ubuntu 20.04 / 22.04 / 24.04 / 26.04.
# Usage:
#   ./contrib/build-ubuntu.sh            # daemon + CLI + GUI if Qt is present
#   ./contrib/build-ubuntu.sh --no-gui   # daemon + CLI only
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

WITH_GUI=1
JOBS="$(nproc 2>/dev/null || echo 2)"
for arg in "$@"; do
  case "${arg}" in
    --no-gui) WITH_GUI=0 ;;
    -j*) JOBS="${arg#-j}" ;;
    *) echo "Unknown argument: ${arg}" >&2; exit 1 ;;
  esac
done

if [[ ! -f /etc/os-release ]]; then
  echo "This helper targets Ubuntu. /etc/os-release not found." >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
echo "Detected ${NAME:-Linux} ${VERSION_ID:-unknown}"

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential libtool bsdmainutils autotools-dev autoconf pkg-config automake \
  python3 curl git \
  libssl-dev libgmp-dev libevent-dev libboost-all-dev libsodium-dev \
  libminiupnpc-dev libzmq3-dev

if [[ "${WITH_GUI}" -eq 1 ]]; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libqt5gui5 libqt5core5a libqt5dbus5 libqt5svg5-dev \
    qttools5-dev qttools5-dev-tools \
    libprotobuf-dev protobuf-compiler libqrencode-dev || true
  # charts package name differs slightly across releases; ignore if missing
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y libqt5charts5-dev || true
fi

# Prefer Berkeley DB 4.8 via the bundled helper (works on all supported Ubuntu).
if [[ ! -d "${ROOT}/db4" ]]; then
  echo "Building Berkeley DB 4.8 into ${ROOT}/db4 ..."
  ./contrib/install_db4.sh "${ROOT}"
fi
export BDB_PREFIX="${ROOT}/db4"

if [[ ! -x ./configure ]]; then
  ./autogen.sh
fi

CONFIG_ARGS=(
  "CPPFLAGS=-I${BDB_PREFIX}/include"
  "LDFLAGS=-L${BDB_PREFIX}/lib"
  --disable-tests
  --disable-bench
)
if [[ "${WITH_GUI}" -eq 0 ]]; then
  CONFIG_ARGS+=(--without-gui)
fi

# Ubuntu 22.04+ ships OpenSSL 3; Ubuntu 20.04 ships 1.1.1. Both are supported.
./configure "${CONFIG_ARGS[@]}"
make -j"${JOBS}"

echo
echo "Build finished."
echo "  Daemon: ${ROOT}/src/Lightcoind"
echo "  CLI:    ${ROOT}/src/Lightcoin-cli"
if [[ "${WITH_GUI}" -eq 1 ]]; then
  echo "  GUI:    ${ROOT}/src/qt/Lightcoin-qt"
fi
