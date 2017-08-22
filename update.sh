#!/bin/bash

function make_clean()
{
	echo "make clean"
}

function move_bin()
{
	echo "move bin"
}

function make_decoder()
{
	echo "make decoder"
}

function make_arch()
{
	echo "make arch"
}

function make_decoder_image()
{
	echo "make image"
}

build_help()
{
	echo "no option chosice"
	echo " -a --make arch"
	echo " -c --make clean"
	echo " -d --make decoder"
	echo " -i --make decoder.image"
	echo " -m --cp decoder_main.bin to nfsroot"
	echo " -w --make fb_welcome.bin "
	echo " -h --display this help"
	echo "make decoder"
}

function build_welcom()
{
	echo "build welcom"

}

GETOPTOUT=`getopt acdhimwe:fo "$@"`
SETOUT=`set -- "$GETOPTOUT"`

echo "======="
echo "optout is $GETOPTOUT"            #这个变量没有用，只是为查看getopt 命令的输出
echo "setout is $SETOUT"                    #只为查看set -- 命令的输出
echo "after set $@ " 


#================================================
if [ $# == 0 ]; then
	build_help
fi

set -- `getopt acdhimwe:fo "$@"`                              #set -- 重新组织$1 等参数
while  [ -n "$1" ]
do
	echo "\$1 is $1"
	case $1 in
		-a)
			make_arch
			;;
		-c)
			make_clean
			;;
		-d)
			make_decoder
			;;
		-h)
			build_help
			;;
		-i)
			make_decoder_image
			;;
		-m)
			move_bin
			;;
		-w)
			build_welcom
			;;
		--)
			shift
			break
			;;
		-o)
			echo "find -o option"
			;;
		-f)
			echo "find -f option"
			;;
		-e)
			echo "find -e option with param $2"
			shift
			;;
		*)
			echo $1
			echo "unknow option"
	esac
	shift
done

count=1
for param in "$@"
do
	echo "Paraneter \$$count:$param"
	count=$[ $count + 1 ]

done

