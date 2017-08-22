#!/bin/bash 

update_ref="open_platform_demo.txt"

avalible_update_list=(
	dolphin_cantv_h2
	external_product
	customer_ir
)

function check_syntax()
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

function write_source()
{
	return 0
}

function process_field_value()
{
	#读配置文件，一行中的[]中的字段与var比较，如果有说明支持，则解析出 key 和 value

	#while read line
	for var in ${avalible_update_list[*]}; do
		#if 支持
		#将 key 和 value 设置到var对应的文件当中
		write_source $var $key $value
		#else continue
	done

    return 0
}

function set_sourcelist()
{
		process_field_value  $var

	return 0
}

check_syntax $update_ref
echo "check syntax status:$?"

set_sourcelist $update_ref
echo "set source status:$?"
