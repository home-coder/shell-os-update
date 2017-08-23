#!/bin/bash

#待解析的云更新配置文件清单
update_ref="cantv_h2.ini"

#本地支持更新资源文件列表，
avalible_update_list=(
	dolphin_cantv_h2
	external_product
	customer_ir
)

#本地支持列表所对应的资源文件路径
dolphin_cantv_h2_file="dolphin_cantv_h2.mk"
external_product_file="external_product.txt"
customer_ir_file="" #需要根据vendor_code配置kl文件名

function check_manifest_syntax()
{
    if [ ! -f $1 ];then 
        return 1
    fi
 
    ret=$(awk -F= 'BEGIN{valid=1}
    {
        if(valid == 0) next
        if(length($0) == 0) next
        gsub(" |\t","",$0)
        head_char=substr($0,1,1)
        if (head_char != "#"){
            if( NF == 1){
                b=substr($0,1,1)
                len=length($0)
                e=substr($0,len,1)
                if (b != "[" || e != "]"){
                    valid=0
                }
            }else if( NF == 2){
                b=substr($0,1,1)
                if (b == "["){
                    valid=0
                }
            }else{
                valid=0
            }
        }
    }
    END{print valid}' $1)
 
    if [ $ret -eq 1 ];then
        return 0
    else
        return 2
    fi
}

function write_mk_file()
{
#test 假设传过来的参数如下
	echo "write_mk_file"
	param_file='dolphin_cantv_h2.mk'
	param_key='PRODUCT_MANUFACTURER'
	param_value='忆典'
	echo $param_file $param_key $param_value

	grep -r ^$param_key $param_file
	if [ $? -eq 0 ]; then
		sed -i '/^'$param_key'/s/\(.*\):=.*/\1:= '$param_value'/g' $param_file
	else
		add_prop="$param_key := $param_value"
		echo "$add_prop" >> $param_file
	fi
}

function write_txt_file()
{
	echo "write_txt_file"
}

function write_kl_file()
{
	echo "write_kl_file"
}

function process_field_value()
{
	case $1 in
	'dolphin_cantv_h2')
		if [ -w $dolphin_cantv_h2_file ]; then
			write_mk_file
		else
			echo -e "\033[0;31;1m------$dolphin_cantv_h2_file not exist, error----\033[0m"
		fi
	;;
	'external_product')
		if [ -w $external_product_file ]; then
			write_txt_file
		else
			echo -e "\033[0;31;1m------$external_product_file not exist, error----\033[0m"
		fi
	;;
	###'customer_ir_file')
	#TODO write_kl_file
	esac

	return 0
}

function update_sourcelist()
{
	#TODO while read line BEG ---->
		#读配置文件，一行中的[]中的字段与var比较，如果有说明支持，则解析出 key 和 value
		for var in ${avalible_update_list[*]}; do
			#if 支持且不是customer_ir 将 key 和 value 设置到var对应的文件当中
			if [ $var != 'customer_ir' ]; then
				process_field_value $var $key $value
			else
				echo -e "\033[0;31;1m------${var}_file maybe not exist, creat----\033[0m"
				#TODO 是customer_ir的情况，首先获取customer_code的直 如果不存在则创建customer_ir_$customer_code.kl文件=parsel_file，然后在重新解析key value且不包含customer_code
				process_field_value $pasel_file $key $value 
			fi
		done

	#TODO while read line  END <-----
	
    return 0
}

#解析云配置清单的入口处
check_manifest_syntax $update_ref
if [ $? != 0 ]; then
	echo -e "\033[0;31;1m------check syntax status:$?, error----\033[0m"
	exit
fi

update_sourcelist $update_ref
echo "set source status:$?"
