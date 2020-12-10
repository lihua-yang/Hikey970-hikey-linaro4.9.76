compile aosp 9.0 (P) for hikey970
=====
编译AOSP for hikey970
-----
两个重要的官方参考网站：  
https://www.96boards.org/documentation/consumer/hikey/hikey970/build/aosp.md.html     
https://www.96boards.org/documentation/consumer/hikey/hikey970/build/linux-kernel.md.html     
repo init -u https://android.googlesource.com/platform/manifest -b master   
一般，先在宿舍在镜像源下载最新版本的aosp。repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest      
进入aosp路径后：    
git clone https://github.com/96boards-hikey/android-manifest.git -b hikey970_v1.0 .repo/local_manifests       
repo sync -j8    



编译Hikey-linaro
-----
git clone https://github.com/96boards-hikey/linux.git
make ARCH=arm64 hikey960_defconfig     
