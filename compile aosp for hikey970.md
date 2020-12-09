compile aosp 9.0 (P) for hikey970
=====
编译AOSP for hikey970
-----
repo init -u https://android.googlesource.com/platform/manifest -b master   
一般，先在宿舍在镜像源下载最新版本的aosp。
进入aosp路径后：    
git clone https://github.com/96boards-hikey/android-manifest.git -b hikey970_v1.0 .repo/local_manifests       
repo sync --force-sync -j8    
git clone https://github.com/96boards-hikey/linux.git
