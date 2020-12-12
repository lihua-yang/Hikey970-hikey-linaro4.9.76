compile aosp 9.0 (P) for hikey970
=====
编译AOSP for hikey970
-----
编译时主要参考网站的帖子：     
http://www.arm-cn.com/thread-1208-1-1.html     
两个重要的官方参考网站：  
https://www.96boards.org/documentation/consumer/hikey/hikey970/build/aosp.md.html     
https://www.96boards.org/documentation/consumer/hikey/hikey970/build/linux-kernel.md.html     
repo init -u https://android.googlesource.com/platform/manifest -b master   
一般，先在宿舍在镜像源下载最新版本的aosp。repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest      
进入aosp路径后：    
git clone https://github.com/96boards-hikey/android-manifest.git -b hikey970_v1.0 .repo/local_manifests       
repo sync -j8    


lunch hikey970-userdebug时报错：    
build/make/core/product_config.mk:234: error: Can not locate config makefile for product "hikey970".     
09:56:10 dumpvars failed with: exit status 1      
首先修改device/linaro/hikey目录下的AndroidProducts.mk, 添加$(LOCAL_DIR)/hikey970.mk.    
然后接着报错：     
frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk:19: error: _nic.PRODUCTS.[[device/linaro/hikey/hikey970.mk]]: "device/linaro/hikey/hikey970/device-hikey970.mk" does not exist.     
在/mnt/hikey970/aosp/device/linaro/hikey目录下将github上aosp-device-linaro-hikey中的hikey970文件夹复制到此处，总之，缺少的东西想办法补齐 


编译Hikey-linaro
-----
git clone https://github.com/96boards-hikey/linux.git    
sudo git checkout -b origin/hikey970-v4.9      
make ARCH=arm64 hikey960_defconfig     
