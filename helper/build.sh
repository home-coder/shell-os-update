#!/bin/bash
number=`cat /proc/cpuinfo |grep processor|wc -l`
export ROOT_PATH=$(pwd)/../..
export ANDROID_PATH=$ROOT_PATH/Allwinner-h2
export LICHEE_PATH=$ROOT_PATH/lichee
export JAVA_HOME=/opt/jdk1.6.0_43/
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
echo $ROOT_PATH
echo $ANDROID_PATH
echo $LICHEE_PATH
echo $PATH

# First build lichee
cd $LICHEE_PATH
#Build so manytimes,so choice in the select_lunch cmd
#./build.sh -p sun8iw7p1_android -c dolphin
## Second build android
cd $ANDROID_PATH
source build/envsetup.sh
lunch dolphin_cantv_h2-eng
#make clean
#extract-bsp
#make -j$number
pack -s -f
#get_uboot
#make otapackage
