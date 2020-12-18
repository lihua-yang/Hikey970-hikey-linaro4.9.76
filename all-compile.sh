#!/bin/bash
cd kernel/linux
export ARCH=arm64    
export CROSS_COMPILE=/mnt/hikey970/aosp/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-  
     
make hikey970_defconfig && make -j32      

cp /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb /mnt/hikey970/aosp/device/linaro/hikey-kernel/kirin970-hikey970.dtb-4.9    
cp /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/Image.gz /mnt/hikey970/aosp/device/linaro/hikey-kernel/Image.gz-hikey970-4.9   
 
cd ../..
source build/envsetup.sh     
lunch hikey970-userdebug   
make -j$(nproc) BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE=f2fs TARGET_USERIMAGES_USE_F2FS=true     

./build_kernel.sh
