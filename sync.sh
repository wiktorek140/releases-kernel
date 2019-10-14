#!/bin/bash
source config.sh
SYNC_START=$(date +"%s")
telegram -M "Sync started for [${name}](${kernel})"
git clone "${kernel}" --depth 1 -b "${branch}" kernel
git clone git://github.com/JarlPenguin/AnyKernel3 --depth 1 AnyKernel
if [ "${clang}" == "true" ]; then
    git clone git://github.com/PixelExperience/prebuilts_clang_host_linux-x86 --depth 1 -b pie clang
fi
if [ "${ARCH}" == "arm" ]; then
    git clone git://github.com/JarlPenguin/prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 --depth 1 gcc
elif [ "${ARCH}" == "arm64" ]; then
    git clone git://github.com/JarlPenguin/prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --depth 1 gcc
fi
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ -d "kernel" ] && [ -d "gcc" ] && [ -d "AnyKernel" ]; then
    telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
else
    telegram -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
fi