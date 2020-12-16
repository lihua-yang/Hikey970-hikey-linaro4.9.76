编译纯版
================
编译AOSP    
```
 cd /mnt/hikey970/aosp/kernel/linux    
 export ARCH=arm64    
 export CROSS_COMPILE=/mnt/hikey970/aosp/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-  
 
 make hikey970_defconfig && make -j4 Image.gz modules   
 make hisilicon/kirin970-hikey970.dtb   
 或直接为    
 make hikey970_defconfig && make -j32      

 cp /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb /mnt/hikey970/aosp/device/linaro/hikey-kernel/kirin970-hikey970.dtb-4.9    
 cp /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/Image.gz /mnt/hikey970/aosp/device/linaro/hikey-kernel/Image.gz-hikey970-4.9   
 
 cd ../..
 source build/envsetup.sh     
 lunch hikey970-userdebug   
 make -j$(nproc) BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE=f2fs TARGET_USERIMAGES_USE_F2FS=true    
 or    
 make -j32 ramdisk    
 ```
 
 用到上述生成的ramdisk.img编译boot.img
=========
cp /mnt/hikey970/aosp/out/target/product/hikey970/ramdisk.img /mnt/hikey970/aosp/ramdisk.img    
cat /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/Image /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb > /mnt/hikey970/aosp/Image-dtb    
/mnt/hikey970/aosp/out/host/linux-x86/bin/mkbootimg --kernel Image-dtb --ramdisk ramdisk.img --cmdline "androidboot.hardware=hikey970 firmware_class.path=/system/etc/firmware loglevel=15 buildvariant=userdebug androidboot.selinux=permissive clk_ignore_unused=true initrd=0xBE19D000,0x16677F earlycon=pl011,0xfff32000,115200 console=ttyAMA6 androidboot.serialno=54DA9CD5022525E4 clk_ignore_unused=true" -o boot.img   
cp /mnt/hikey970/aosp/boot.img /mnt/hikey970/aosp/out/target/product/hikey970/boot_built.img      
or cp /mnt/hikey970/aosp/boot.img /mnt/hikey970/aosp/out/target/product/hikey970/boot.img   
或者：    
./out/host/linux-x86/bin/mkbootimg --kernel Image-dtb --ramdisk ramdisk.img --cmdline "androidboot.hardware=hikey970 firmware_class.path=/system/etc/firmware loglevel=15 buildvariant=userdebug androidboot.selinux=permissive clk_ignore_unused=true root=/dev/sdd12 rootwait skip_initramfs init=/init" --base 0x0 --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x07c00000 --os_version 9.0 --os_patch_level 2016-08-05 --output out/target/product/hikey970/boot.img     
   

刷录镜像，使用update_Hikey970.bat   或者    
fastboot flash ptable prm_ptable.img    
fastboot flash xloader sec_xloader.img   
fastboot flash fastboot l-loader.bin   
fastboot reboot-bootloader   
fastboot flash fip fip.bin   
fastboot flash boot boot.img   
fastboot flash cache cache.img   
fastboot flash system system.img   
fastboot flash userdata userdata.img   

