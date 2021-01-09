#!/bin/bash
source config.sh
SYNC_START=$(date +"%s")
telegram -M "Sync started for [${name}](${kernel})"
git clone "${kernel}" -b "${branch}" kernel
git clone git://github.com/JarlPenguin/AnyKernel3 --depth 1 AnyKernel
if [ "${clang}" == "true" ]; then
    git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 --depth 1 -b android-11.0.0_r8 clang
fi
if [ "${ARCH}" == "arm" ]; then
    git clone git://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 --depth 1 gcc
elif [ "${ARCH}" == "arm64" ]; then
    git clone git://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 --depth 1 gcc32
    git clone git://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --depth 1 gcc
fi
cd ./kernel/
git config --global user.email "wiktorek140@tlen.pl"
git config --global user.name "wiktor"

git fetch
git cherry-pick 4dcb1f152f2fec75500f81154cbfa8a2df271b4c
git cherry-pick ac069951b776f3aed88695a674cfe0a4f572f270
git cherry-pick 6d9925d839b24a3ef8ad1fdeacc381e2e9e51831
cd ./..

SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ -d "kernel" ] && [ -d "gcc" ] && [ -d "AnyKernel" ]; then
    telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
else
    telegram -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    exit 1
fi
