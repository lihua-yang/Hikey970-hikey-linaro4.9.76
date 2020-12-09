#!/bin/bash
DTB=1
LOCAL_DIR=$(pwd)
KERNEL_DIR=${LOCAL_DIR}/linux 
PRODUCT_OUT=${LOCAL_DIR}/out/target/product/hikey970 
GEN_IMAGES_DIR=${LOCAL_DIR}/tools 
HIKEY970_KERNEL=${LOCAL_DIR}/tools
MKBOOTTOOL_DIR=${LOCAL_DIR}/tools 
CURRENT_DIR=${LOCAL_DIR} 
NCPU=`grep -c ^processor /proc/cpuinfo`

if [ ! -e ${PRODUCT_OUT} ] 
then 
    mkdir -p ${PRODUCT_OUT} 
fi

export MINI_SYS=true
export ARCH=arm64 
#export CROSS_COMPILE=~/myview/code/hikey970_trunk_new/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE=/mnt/ssd/android-ndk-r14b/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-

function check_build_result() 
{ 
    if [ $? != 0 ]; then 
        echo -e "\033[31m $1 build fail! \033[0m" 
        exit -1 
    else echo -e "\033[32m $1 build success! \033[0m" 
    fi 
}

if [ "${MINI_SYS}" != true ]; then 
    source ./build/envsetup.sh && lunch hikey970-userdebug && make -j$[NCPU*2] $2 
    check_build_result "Android System" 
fi

cd ${KERNEL_DIR}

make hikey970_defconfig && \ 
make -j$[NCPU*2] Image.gz modules

check_build_result "Kernel Image" 
rm -f arch/arm64/configs/hikey970_temp_defconfig

cp arch/arm64/boot/Image.gz ${HIKEY970_KERNEL} 
if [ $DTB -eq 1 ]; then 
    make hisilicon/kirin970-hikey970.dtb 
    check_build_result "Hikey970 dtb" 
    cp arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb ${HIKEY970_KERNEL} 
fi

cd ${CURRENT_DIR}

if [ ${need_repack_userdata} ]; 
then 
    make -j$[NCPU*2] userdataimage-nodeps 
    check_build_result "Hikey970 need repack userdataimage" 
fi

if [ "${MINI_SYS}" = true ]; then 
    RAMDISK=${GEN_IMAGES_DIR}/ramdisk.img 
else 
    RAMDISK=${PRODUCT_OUT}/ramdisk.img 
    if [ ! -e $RAMDISK ]; then 
        echo -e "\033[33m $RAMDISK is not exist! please build ramdisk first. \033[0m" 
        echo -e "\033[33m . ./build/envsetup.sh && lunch hikey960-userdebug && make ramdisk \033[0m" 
        exit -1 
    fi 
fi

#uefi boot.img = Image + dtb + ramdisk 
cat ${KERNEL_DIR}/arch/arm64/boot/Image ${KERNEL_DIR}/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb > ${HIKEY970_KERNEL}/Image-dtb 
check_build_result "Image-dtb"

${MKBOOTTOOL_DIR}/mkbootimg --kernel ${HIKEY970_KERNEL}/Image-dtb --ramdisk
${RAMDISK} --cmdline "androidboot.hardware=hikey970 firmware_class.path=/system/etc/firmware loglevel=15 buildvariant=userdebug androidboot.selinux=permissive clk_ignore_unused=true" --base 0x0 --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x07c00000 --os_version 7.0 --os_patch_level 2016-08-05 --output ${PRODUCT_OUT}/boot.img
check_build_result "Boot Image"

echo -e "\033[36m build boot.img complete! \033[0m"

#export CROSS_COMPILE=/home/xxxxxx/hikey970/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
#export CROSS_COMPILE=/mnt/ssd/android-ndk-r14b/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-
