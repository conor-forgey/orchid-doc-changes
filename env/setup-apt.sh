#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update

apt-get -y install \
    bc tcl xxd \
    curl git-core rsync wget \
    fakeroot libtalloc-dev \
    cpio rpm unzip zstd \
    clang clang-tidy lld \
    libc++-dev libc++abi-dev \
    g++-multilib gcc-multilib \
    python3-pip python3-setuptools \
    openjdk-11-jre-headless \
    bison flex gperf \
    gettext groff texinfo \
    autoconf autoconf-archive automake \
    libtool ninja-build pkg-config \

function usable() {
    # Ubuntu bionic ships meson 0.45, which is too old to build glib
    # XXX: consider checking for meson 0.52 (it broke cross linking)

    # Ubuntu focal ships meson 0.53, which is still incompatible with the lld that comes in the r22 Android NDK
    # meson passes --allow-shlib-undefined to lld, which only recently added it https://reviews.llvm.org/D57385
    # this bug is now fixed in meson, but also not until recently https://github.com/mesonbuild/meson/pull/5912

    for version in $(apt-cache show meson | sed -e '/^Version: */!d;s///'); do
        if dpkg --compare-versions "${version}" ">=" "0.54.0"; then
            return
        fi
    done
false; }

if usable; then
    apt-get -y install meson
else
    pip3 install meson
fi
