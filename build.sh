#!/bin/bash
source config.sh
export SUBARCH="${ARCH}"

if [ "${ARCH}" == "arm" ]; then
    export kernel_toolchain="arm-linux-androideabi-"
    export kernel_clang_triple="arm-linux-gnu-"
elif [ "${ARCH}" == "arm64" ]; then
    export kernel_toolchain="aarch64-linux-android-"
    export kernel_clang_triple="aarch64-linux-gnu-"
fi
if [ "${clang}" == "false" ]; then
    export CROSS_COMPILE="$(pwd)/gcc/bin/${kernel_toolchain}"
elif [ "${clang}" == "true" ]; then
    PATH="${PATH}:$(pwd)/clang/bin:$(pwd)/gcc/bin"
fi
if [ "${name}" == "" ]; then
    export name="Generic ${device} kernel"
fi

BUILD_START=$(date +"%s")
cd kernel
telegram -M "Build started for ${device}"
if [ "${clang}" == "true" ]; then
    make O=out ARCH="${ARCH}" "${defconfig}"
    make -j$(nproc --all) O=out ARCH="${ARCH}" CC=clang CLANG_TRIPLE="${kernel_clang_triple}" CROSS_COMPILE="${kernel_toolchain}"
else
    mkdir -p out
    make O=out "${defconfig}"
    make O=out -j$(nproc --all)
fi
cd ..
function pack_zip () {
    export zip_name="kernel-$(date +%Y%m%d-%H%M)-${device}.zip"
    cd AnyKernel
    if [ "${device_is_ab}" == "true" ]; then
        sed -i 's|is_slot_device=0|is_slot_device=1|g' anykernel.sh
    fi
    sed -i "s|device_name1=|device_name1=${device}|g" anykernel.sh
    sed -i "s|kernel_string=|kernel_string=${name}|g" anykernel.sh
    zip -r9 "${zip_name}" * "${zip_name}"
    cd ..
}
if [ "${ARCH}" == "arm" ]; then
    if [ -f kernel/out/arch/arm/boot/Image ]; then
        if [ -f kernel/out/arch/arm/boot/zImage-dtb ]; then
            cp kernel/out/arch/arm/boot/zImage-dtb AnyKernel/
        else
            cp kernel/out/arch/arm/boot/zImage AnyKernel/
        fi
        pack_zip
        BUILD_END=$(date +"%s")
        BUILD_DIFF=$((BUILD_END - BUILD_START))
        curl -v -F "chat_id=$TELEGRAM_CHAT" -F document="@AnyKernel/${zip_name}" -F "parse_mode=html" -F caption="Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds" "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument"
    else
        BUILD_END=$(date +"%s")
        BUILD_DIFF=$((BUILD_END - BUILD_START))
        telegram -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    fi
fi
if [ "${ARCH}" == "arm64" ]; then
    if [ -f kernel/out/arch/arm64/boot/Image ]; then
        if [ -f kernel/out/arch/arm64/boot/Image.gz-dtb ]; then
            cp kernel/out/arch/arm64/boot/Image.gz-dtb AnyKernel/
        else
            cp kernel/out/arch/arm64/boot/Image.gz AnyKernel/
        fi
        pack_zip
        BUILD_END=$(date +"%s")
        BUILD_DIFF=$((BUILD_END - BUILD_START))
        curl -v -F "chat_id=$TELEGRAM_CHAT" -F document="@AnyKernel/${zip_name}" -F "parse_mode=html" -F caption="Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds" "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument"
    else
        BUILD_END=$(date +"%s")
        BUILD_DIFF=$((BUILD_END - BUILD_START))
        telegram -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    fi
fi
