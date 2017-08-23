#!/bin/sh
function write_mk_file() 
{
	#test
	echo "write_mk_file"
	param_file="dolphin_cantv_h2.mk"
	param_key="PRODUCT_MANUFACTURER"
	param_value="忆典"
	echo $param_file $param_key $param_value
	
	grep -r ^$param_key $param_file
	if [ $? -eq 0 ]; then
		sed -i '/^'$param_key'/s/\(.*\):=.*/\1:= '$param_value'/g' $param_file
	else
		add_prop="$param_key := $param_value"
		echo $add_prop
		echo $add_prop >> $param_file
	fi
}

function write_txt_file()
{
	param_file="external_product.txt"
	param_key="BOX-4"
	param_value="迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com"
	echo $param_file $param_key $param_value
	
	grep -r ^$param_key $param_file
	if [ $? -eq 0 ]; then
		sed -i '/^'$param_key='/s/.*/'$param_key'='$param_value',/g' $param_file
	else
		add_prop="$param_key=$param_value,"
		echo $add_prop >> $param_file
	fi
}

function write_kl_file()
{
	param_file="customer_ir_df00.kl"
	param_key="10"
	param_value="BACK"

	while read line; do
		arry=($(echo $line | awk -F ' ' '{for(i=1; i <=NF; i++) print $i}'))
		echo ${arry[*]}
	done < $param_file

	info=/home/jiangxiujie/mstar-638-tv/Mstar-638/build/build_config/build_info_C49S.txt
	echo `sed -i '/kuyun:/p' $info` | gawk -F ' ' '{print $2}' | sed 's/;//'
	echo `sed -n '/kuyun:/p' $info` | gawk -F ':' '{print $2}' | sed 's/.$//' #最后一个字符去掉
}

#write_mk_file
#write_txt_file
write_kl_file
