#!/bin/bash
set -e
which brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install autoconf autoconf-archive automake capnp fakeroot groff libtool meson rpm2cpio rustup-init zstd
rustup-init -y --no-modify-path --no-update-default-toolchain
env/setup-all.sh
