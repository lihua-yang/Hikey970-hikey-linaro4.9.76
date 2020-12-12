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
$ export CROSS_COMPILE=$AOSP_ROOT/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
$ make hikey970_defconfig && make -j4 Image.gz modules
$ make hisilicon/kirin970-hikey970.dtb

$ cp $AOSP_ROOT/kernel/linux/arch/arm64/boot/dts/hisilicon/kirin970-hikey970.dtb $AOSP_ROOT/device/linaro/hikey-kernel/kirin970-hikey970.dtb-4.9
$ cp $AOSP_ROOT/kernel/linux/arch/arm64/boot/Image.gz $AOSP_ROOT/device/linaro/hikey-kernel/Image.gz-hikey970-4.9

lunch hikey970-userdebug时报错：    
build/make/core/product_config.mk:234: error: Can not locate config makefile for product "hikey970".     
09:56:10 dumpvars failed with: exit status 1      
首先修改device/linaro/hikey目录下的AndroidProducts.mk, 添加$(LOCAL_DIR)/hikey970.mk.    
然后接着报错：     
frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk:19: error: _nic.PRODUCTS.[[device/linaro/hikey/hikey970.mk]]: "device/linaro/hikey/hikey970/device-hikey970.mk" does not exist.     
在/mnt/hikey970/aosp/device/linaro/hikey目录下将github上aosp-device-linaro-hikey中的hikey970文件夹复制到此处，总之，缺少的东西想办法补齐   

make -32
报错：error: 'out/target/product/hikey970/hi3660-hikey960.dtb', needed by 'out/target/product/hikey970/dt.img', missing and no known rule to make it，想起官方文档中的需要复制两个镜像     




   
