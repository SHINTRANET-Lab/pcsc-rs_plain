#!/bin/sh
# Builds pcsc-rs for OpenWrt 18.06 (mipsel_24kc, old musl) with the OpenWrt SDK toolchain.
set -eu

SDK="${OPENWRT_SDK:-$HOME/openwrt-sdk}"
UNWIND="${OPENWRT_UNWIND:-$HOME/openwrt-unwind}"
COMPAT="${OPENWRT_COMPAT:-$HOME/openwrt-compat.o}"
NIGHTLY="${NIGHTLY:-nightly-2026-09-28}"
TARGET=mipsel-unknown-linux-musl

export PATH="$SDK/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin:$PATH"
export STAGING_DIR="$SDK/staging_dir"
export CARGO_TARGET_MIPSEL_UNKNOWN_LINUX_MUSL_LINKER=mipsel-openwrt-linux-musl-gcc
export CC_mipsel_unknown_linux_musl=mipsel-openwrt-linux-musl-gcc
export RUSTFLAGS="-C target-feature=+crt-static -C link-self-contained=no -C link-arg=-static -C link-arg=-L$UNWIND -C link-arg=$COMPAT -C link-arg=-lunwind -C link-arg=-lgcc_eh"

cargo +"$NIGHTLY" build --locked --release -Zbuild-std=std,panic_abort --target "$TARGET"
cp "target/$TARGET/release/pcsc-rs" "pcsc-rs-$TARGET"
