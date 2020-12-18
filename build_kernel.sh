#!/bin/bash
DTB=1
LOCAL_DIR=$(pwd)
KERNEL_DIR=${LOCAL_DIR}/kernel/linux
PRODUCT_OUT=${LOCAL_DIR}/out/target/product/hikey970
HIKEY970_KERNEL=${LOCAL_DIR}/device/linaro/hikey-kernel
#change by ylh
MKBOOTTOOL_DIR=${LOCAL_DIR}/out/host/linux-x86/bin
CURRENT_DIR=${LOCAL_DIR}
NCPU=`grep -c ^processor /proc/cpuinfo`

if [ ! -e ${PRODUCT_OUT} ]
then
	mkdir -p ${PRODUCT_OUT}
fi

export ARCH=arm64
export CROSS_COMPILE=${CURRENT_DIR}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-

function check_build_result()
{
	if [ $? != 0 ]; then
		echo -e "\033[31m $1 build fail! \033[0m"
		exit -1
	else
		echo -e "\033[32m $1 build success! \033[0m"
	fi
}

cd ${KERNEL_DIR}

make hikey970_defconfig && \
make -j$[NCPU*2]
# change by ylh
#make -j$[NCPU*2]

check_build_result "Kernel Image"
rm -f arch/arm64/configs/hikey970_temp_defconfig

cp arch/arm64/boot/Image.gz ${HIKEY970_KERNEL}

if [ $DTB -eq 1 ]; then
	make hisilicon/kirin970-hikey970.dtb
	check_build_result "Hikey970 dtb"
	cp arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb ${HIKEY970_KERNEL}
	
	cp arch/arm64/boot/Image.gz ${HIKEY970_KERNEL}/Image.gz-hikey970-4.9
	cp arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb ${HIKEY970_KERNEL}/kirin970-hikey970.dtb-4.9
fi

cd ${CURRENT_DIR}

RAMDISK=${PRODUCT_OUT}/ramdisk.img

if [ ! -e $RAMDISK ]; then
	. ./build/envsetup.sh && lunch hikey970-userdebug && make ramdisk
	check_build_result "Ramdisk Image"
fi

if [ ! -e $RAMDISK ]; then
	echo -e "\033[33m $RAMDISK is not exist! please build ramdisk first. \033[0m"
	echo -e "\033[33m . ./build/envsetup.sh && lunch hikey970-userdebug && make ramdisk \033[0m"
	exit -1
fi

#uefi boot.img = Image + dtb + ramdisk
#add by ylh
#cp /mnt/hikey970/aosp/out/target/product/hikey970/ramdisk.img ${LOCAL_DIR}/ramdisk.img
cat ${KERNEL_DIR}/arch/arm64/boot/Image ${KERNEL_DIR}/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb > ${HIKEY970_KERNEL}/Image-dtb
check_build_result "Image-dtb"
${MKBOOTTOOL_DIR}/mkbootimg --kernel ${HIKEY970_KERNEL}/Image-dtb --ramdisk ${RAMDISK} --cmdline "androidboot.hardware=hikey970 firmware_class.path=/system/etc/firmware loglevel=15 buildvariant=userdebug androidboot.selinux=permissive clk_ignore_unused=true initrd=0xBE19D000,0x16677F earlycon=pl011,0xfff32000,115200 console=ttyAMA6 androidboot.serialno=54DA9CD5022525E4 clk_ignore_unused=true" --output ${PRODUCT_OUT}/boot.img
#https://discuss.96boards.org/t/why-is-there-a-difference-between-contents-of-source-built-and-pre-built-system-images/6741/2
#modified by ylh
#${MKBOOTTOOL_DIR}/mkbootimg --kernel ${HIKEY970_KERNEL}/Image-dtb --ramdisk ${RAMDISK} --cmdline "androidboot.hardware=hikey970 firmware_class.path=/system/etc/firmware loglevel=15 buildvariant=userdebug androidboot.selinux=permissive clk_ignore_unused=true" --base 0x0 --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x07c00000 --os_version 7.0 --os_patch_level 2016-08-05  --output ${PRODUCT_OUT}/boot.img
#${MKBOOTTOOL_DIR}/mkbootimg --kernel ${HIKEY970_KERNEL}/Image-dtb --ramdisk ${RAMDISK} --cmdline "androidboot.hardware=hikey970 firmware_class.path=/system/etc/firmware loglevel=15 buildvariant=userdebug androidboot.selinux=permissive clk_ignore_unused=true root=/dev/sdd12 rootwait skip_initramfs init=/init" --base 0x0 --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x07c00000 --os_version 9.0 --os_patch_level 2016-08-05 --output ${PRODUCT_OUT}/boot.img
check_build_result "Boot Image"

echo -e "\033[36m build boot.img complete! \033[0m"
