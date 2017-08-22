#!/bin/bash
############################only android can use this shell######################
if [ $(whoami) != "android" ];then
 echo "User name is not android!!!!!!Only android can execute!!!!!!"
 exit
else
 echo "I am android"
fi

set -e
##############################build android######################################
export JAVA_HOME=/opt/jdk1.6.0_43/
export PATH=/opt/toolchain/amlogic/gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux/bin:/opt/toolchain/amlogic/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux/bin:$PATH
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=/home/android/bin:${JAVA_HOME}/bin:${JRE_HOME}/bin:/sbin:$PATH
export ROOT_PATH=$WORKSPACE/Allwinner-h2/
export LICHEE_PATH=$WORKSPACE/lichee

if [ "$OTA"x == "true"x ] ; then
    if [ "$Branch"x == "master"x ] ; then
        now_branch=`date +%Y%m%d%k%M`
        new_branch=H2_V1.1_$now_branch"_ota"
        android_branch=`git remote`
        echo $new_branch
        repo start $new_branch --all
        repo forall -c "git push $android_branch $new_branch"
        cd $WORKSPACE/.repo/manifests
        repobranch=`git remote`
        git checkout -b $new_branch
        sed -i s/revision=\"master\"/revision=\"$new_branch\"/g default.xml
        git diff
        git add default.xml
        git commit -m "new branch $1"
        git push $repobranch $new_branch
        cd -
        ##checkout new branch
    fi
fi

echo $ROOT_PATH
cd $ROOT_PATH

number=`cat /proc/cpuinfo |grep processor|wc -l`

find out -name build.prop|xargs rm -rf
rm -rf out/target/product/dolphin-cantv-h2/system/app
rm -rf out/target/product/dolphin-cantv-h2/dolphin_cantv_h2-ota-*.zip
rm -rf out/target/product/dolphin-cantv-h2/obj/PACKAGING/target_files_intermediates/dolphin_cantv_h2-target_files-*
rm -rf $LICHEE_PATH/tools/pack/sun8iw7p1_android_dolphin-p2_uart0_secure*.img


# First build lichee
cd $LICHEE_PATH
#Build so manytimes,so choice in the select_lunch cmd
./build.sh -p sun8iw7p1_android -c dolphin
# Second build android
cd $ROOT_PATH
source build/envsetup.sh
lunch dolphin_cantv_h2-eng
if [ "$Clean"x == "false"x ] ; then
    echo "not make clean"
else
    echo "make clean"
    make clean
fi

extract-bsp
make update-api
make -j$number
pack -s -f
get_uboot
make otapackage

############################version info###################################################
systemversion=`cat out/target/product/dolphin-cantv-h2/system/build.prop | grep "ro.build.version.release" | awk -F "=" '{print $2}'`
echo $systemversion

ver=`cat out/target/product/dolphin-cantv-h2/system/build.prop | grep "ro.build.date.utc" | awk -F "=" '{print $2}'`
echo $ver

platform=`cat out/target/product/dolphin-cantv-h2/system/build.prop | grep "ro.product.model" | awk -F "=" '{print $2}'`
echo $platform

channel=`cat out/target/product/dolphin-cantv-h2/system/build.prop | grep "ro.build.version.channelid=" | awk -F "=" '{print $2}'`
echo $channel

############################firmewire backup path###################################
backuppath="$ver"

yourdate=`date +%Y_%m_%d`
echo $yourdate
if [[ "$Branch"x =~ "ota"x ]] || [ "$OTA"x == "true"x ]
then
    backuppath=$backuppath"_"$yourdate"_ota"
else
    backuppath=$backuppath"_"$yourdate
fi
    backuppath=$backuppath"_DYOS_unify"

local_backuppath=out/target/product/dolphin-cantv-h2/backup/$backuppath
echo $backuppath
echo $local_backuppath

###########################storage firmewire########################################
rm -rf out/target/product/dolphin-cantv-h2/backup/
mkdir -p $local_backuppath
cp out/target/product/dolphin-cantv-h2/dolphin_cantv_h2-ota-*.zip $local_backuppath/update.zip
cp out/target/product/dolphin-cantv-h2/obj/PACKAGING/target_files_intermediates/dolphin_cantv_h2-target_files-*.zip  $local_backuppath/H2-target_files.zip
cp ../lichee/tools/pack/sun8iw7p1_android_dolphin-p2_uart0_secure*.img $local_backuppath

md5_inc=`md5sum $local_backuppath/H2-target_files.zip`
md5_inc=${md5_inc:0:32}
echo "increment md5 = "$md5_inc


##########################upload update package#####################################
echo "uploading..."

if [ "$LocalFile"x == "H2Version"x ] ; then

echo "Upload is set....."

if [ "$Full"x == "true"x ] ; then

    md5_full=`md5sum $local_backuppath/update.zip`
    md5_full=${md5_full:0:32}
    echo "full md5 = "$md5_full

    #increment package
    python scripts/notify_upload.py -s $systemversion -a $ver -m $md5_inc -f H2-target_files.zip -c $channel -p "$platform" -u 0 -l $local_backuppath
    #full package
    python scripts/notify_upload.py -s $systemversion -a $ver -m $md5_full -f update.zip -c $channel -p "$platform" -u 1 -l $local_backuppath

else

    #increment package
    python scripts/notify_upload.py -s $systemversion -a $ver -m $md5_inc -f H2-target_files.zip -c $channel -p "$platform" -u 0 -l $local_backuppath

fi

else

    echo "Upload not set....."

fi

cd $local_backuppath
md5sum * > md5sum.txt
cd -

