compile aosp 9.0 (P) for hikey970
=====
编译AOSP for hikey970
-----
编译时主要参考网站的帖子：     
http://www.arm-cn.com/thread-1208-1-1.html     
两个重要的官方参考网站：  
https://www.96boards.org/documentation/consumer/hikey/hikey970/build/aosp.md.html     
https://www.96boards.org/documentation/consumer/hikey/hikey970/build/linux-kernel.md.html     
官网：    
repo init -u https://android.googlesource.com/platform/manifest -b master   
帖子：     
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b android-9.0.0_r8 --no-repo-verify --repo-branch=stable
获取源码的方式不同，我们在宿舍下载aosp.tar后解压到aosp目录。
一般，先在宿舍在镜像源下载最新版本的aosp。repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest      
进入aosp路径后：    
git clone https://github.com/96boards-hikey/android-manifest.git -b hikey970_v1.0 .repo/local_manifests       
repo sync -j8    

mkdir $AOSP_ROOT/bootloader    
$ sudo apt install uuid-dev build-essential    
$ sudo apt install libssl-dev    
$ git clone https://github.com/96boards-hikey/tools-images-hikey970.git    
$ git clone https://github.com/96boards-hikey/OpenPlatformPkg.git -b hikey970_v1.0    
$ git clone https://github.com/96boards-hikey/arm-trusted-firmware.git -b hikey970_v1.0    
$ git clone https://github.com/96boards-hikey/l-loader.git -b hikey970_v1.0    
$ git clone https://github.com/96boards-hikey/edk2.git -b hikey970_v1.0    
$ git clone https://github.com/96boards-hikey/uefi-tools.git -b hikey970_v1.0    
$    
$ cd edk2    
$ ln -sf ../OpenPlatformPkg    

我也有修改交叉编译的路径：
$ cd $AOSP_ROOT/bootloader/l-loader

$ git diff build_uefi.sh    
diff --git a/build_uefi.sh b/build_uefi.sh    
index 3449246..e7e957d 100755    
--- a/build_uefi.sh    
+++ b/build_uefi.sh    
@@ -43,7 +43,8 @@ case "${SELECT_GCC}" in    
        CROSS_COMPILE=aarch64-linux-gnu-    
        ;;    
"LINARO_GCC_7_1")    
-       AARCH64_GCC_7_1=/opt/toolchain/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/bin/   
+       # AARCH64_GCC_7_1=/opt/toolchain/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/bin/      
+        AARCH64_GCC_7_1=/home/hand/workspace/aosp/bootloader/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/bin/     
        PATH=${AARCH64_GCC_7_1}:${PATH} && export PATH     
        export AARCH64_TOOLCHAIN=GCC5     
        CROSS_COMPILE=aarch64-linux-gnu-    
            
linaro gcc获取：暂时没有用到    
$ wget https://releases.linaro.org/components/toolchain/binaries/7.1-2017.08/aarch64-linux-gnu/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu.tar.xz      

获取linaro源码，与hikey960不同，hikey970是放到aosp下面，完成后会有一个叫linux的文件夹
$ cd $AOSP_ROOT/kernel
$ git clone https://github.com/96boards-hikey/linux.git -b hikey970-v4.9 linux

生成一些.img和.bin文件
$AOSP_ROOT/bootloader/l-loader/build_uefi.sh hikey970

编译Hikey-linaro
-----
$ cd $AOSP_ROOT/kernel/linux    
$ export ARCH=arm64    
$ export CROSS_COMPILE=/mnt/hikey970/aosp/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-    
$ make hikey970_defconfig && make -j4 Image.gz modules    
$ make hisilicon/kirin970-hikey970.dtb    
 
$ cp $AOSP_ROOT/kernel/linux/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb $AOSP_ROOT/device/linaro/hikey-kernel/kirin970-hikey970.dtb-4.9    
$ cp $AOSP_ROOT/kernel/linux/arch/arm64/boot/Image.gz $AOSP_ROOT/device/linaro/hikey-kernel/Image.gz-hikey970-4.9    

source build/envsetup.sh     
lunch hikey970-userdebug     

lunch hikey970-userdebug时报错：    
build/make/core/product_config.mk:234: error: Can not locate config makefile for product "hikey970".     
09:56:10 dumpvars failed with: exit status 1      
首先修改device/linaro/hikey目录下的AndroidProducts.mk, 添加$(LOCAL_DIR)/hikey970.mk.    
然后接着报错：     
frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk:19: error: _nic.PRODUCTS.[[device/linaro/hikey/hikey970.mk]]: "device/linaro/hikey/hikey970/device-hikey970.mk" does not exist.     
在/mnt/hikey970/aosp/device/linaro/hikey目录下将github上aosp-device-linaro-hikey中的hikey970文件夹复制到此处，总之，缺少的东西想办法补齐   

make -j32
报错：error: 'out/target/product/hikey970/hi3660-hikey960.dtb', needed by 'out/target/product/hikey970/dt.img', missing and no known rule to make it，想办法从device/linaro/hikey-kernel中复制一个过去

ninja: error: 'device/linaro/hikey/init.hikey970.power.rc', needed by 'out/target/product/hikey970/root/init.hikey970.power.rc', missing and no known rule to make it
10:41:14 ninja failed with: exit status 1     同样想办法从github文件夹中复制一个过去 

ninja: error: 'device/linaro/hikey/hifi/firmware/hifi-hikey970.img', needed by 'out/target/product/hikey970/system/etc/firmware/hifi/hifi.img', missing and no known rule to make it
10:44:42 ninja failed with: exit status 1    同上办法    

ninja: error: 'device/linaro/hikey/ai/configs/kirin970/ai_config.xml', needed by 'out/target/product/hikey970/system/vendor/etc/hiai/default/ai_config.xml', missing and no known rule to make it      办法同上，这次复制的是整个ai文件夹       

编译后没有生成ramdisk.img，按照官方文档编译生成的ramdisk.img在  out/target/product/generic 目录下，复制到out/target/product/hikey970目录下与aosp目录下    
make -j32 ramdisk


编译boot.img
-------
cat /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/Image /mnt/hikey970/aosp/kernel/linux/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb > /mnt/hikey970/aosp/Image-dtb    
/mnt/hikey970/aosp/out/host/linux-x86/bin/mkbootimg --kernel Image-dtb --ramdisk ramdisk.img --cmdline "androidboot.hardware=hikey970 firmware_class.path=/system/etc/firmware loglevel=15 buildvariant=userdebug androidboot.selinux=permissive clk_ignore_unused=true initrd=0xBE19D000,0x16677F earlycon=pl011,0xfff32000,115200 console=ttyAMA6 androidboot.serialno=54DA9CD5022525E4 clk_ignore_unused=true" -o boot.img    
cp /mnt/hikey970/aosp/boot.img /mnt/hikey970/aosp/out/target/product/hikey970/boot_built.img    


所需镜像与刷录
--------
刷录镜像的官网：https://www.96boards.org/documentation/consumer/hikey/hikey970/installation/linux-fastboot.md.html     
与hikey960中的刷录内容有区别，与帖子中的刷录内容也有区别     
$ sudo fastboot flash ptable prm_ptable.img    
$ sudo fastboot flash xloader sec_xloader.img    
$ sudo fastboot flash fastboot l-loader.bin    
$ sudo fastboot flash fip fip.bin    
$ sudo fastboot flash boot boot.img    
$ sudo fastboot flash cache cache.img    
$ sudo fastboot flash system system.img    
$ sudo fastboot flash userdata userdata.img     

以下为尝试帖子中的做法
-------
sec_xloader.img用的是Hikey970image中的，原生的，没有编译过的    
fip.bin、l-loader.bin用的是bootloader/l-loader文件夹下的     
out/target/product/hikey970目录下没有system.img，用的是out/target/product/generic目录下的    
$ cd $AOSP_ROOT/bootloader    
$ fastboot flash ptable l-loader/ptable-aosp-64g.img    
$ fastboot reboot    
$ fastboot flash xloader tools-images-hikey970/sec_xloader.img    
$ fastboot flash fip l-loader/fip.bin    
$ fastboot flash fastboot l-loader/l-loader.bin     
$ fastboot reboot    
$ cd $AOSP_ROOT/out/target/product/hikey970    
$ fastboot flash boot boot_built.img // 注意这里不要烧写原生 boot.img    
$ fastboot flash cache cache.img    
$ fastboot flash system system.img    
$ fastboot flash userdata userdata.img     
       
       
刷录遇到的问题
-------
（1）刷录各种镜像成功，但是adb找不到设备,这也是一种新的生成boot.img的方法    
#####
将$aosp/bootloader/tools-images-hikey970/build_kernel.sh复制到$aosp，并将KERNEL_DIR修改为自己存放hikey-linaro的地方，在本次实验中为$aosp/kernel/linux,生成新的boot.img在$aosp/out/target/product/hikey970       

（2）userdata.img镜像刷录失败，重新调整ptable.img和userdata.img的对应属性，同时将data分区修改为f2fs。主要参考以下帖子：   
https://discuss.96boards.org/t/booting-hikey970-with-f2fs-data-partition/6949      
修改/mnt/hikey970/aosp/kernel/linux目录下的.config文件，增加如下设置：     
```
CONFIG_F2FS_FS=y   
CONFIG_F2FS_STAT_FS=y   
CONFIG_F2FS_FS_XATTR=y   
CONFIG_F2FS_FS_POSIX_ACL=y   
CONFIG_F2FS_FS_SECURITY=y   
CONFIG_F2FS_CHECK_FS=y   
CONFIG_F2FS_FS_ENCRYPTION=y   
CONFIG_F2FS_IO_TRACE=y   
CONFIG_F2FS_FAULT_INJECTION=y   
```
   
在$aosp/device/linaro/hikey/hikey970/BoardConfig.mk
```
#add by ylh
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
```     

修改$aosp/device/linaro/hikey/hikey970/fstab.hikey970
```
#/dev/block/sdd15    /data      ext4    discard,noauto_da_alloc,data=ordered,user_xattr,discard,barrier=1    wait
#modified by ylh
/dev/block/sdd15    /data      f2fs    discard,noatime,nosuid,nodev                                          wait,check,fileencryption=software,quota
```

在$aosp/device/linaro/hikey/BoardConfigCommon.mk
```
#add by ylh
TARGET_USERIMAGES_USE_F2FS := true
```    

先编译ramdisk.img     
make -j32 ramdisk，并将其拷贝到hikey970目录下
```
[100% 704/704] Target ram disk: out/target/product/generic/ramdisk.img
cp out/target/product/generic/ramdisk.img out/target/product/hikey970/
```
再用该ramdisk重新生成boot.img，接着生成其他所有img     
$aosp/./build_kernel.sh     
make -j$(nproc) BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE=f2fs TARGET_USERIMAGES_USE_F2FS=true         、
新的分区表没有起作用，重启一次    

报错  
```
target reported max download size of 134217728 bytes
erasing 'userdata'...
FAILED (remote: Check device console.)
finished. total time: 0.006s
"Update Failed!"
```
