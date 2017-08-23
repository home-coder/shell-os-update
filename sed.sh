#!/bin/sh
function write_mk_file() 
{
	#test
	echo "write_mk_file"
	param_file='dolphin_cantv_h2.mk'
	param_key='PRODUCT_MANUFACTURER'
	param_value='忆典'
	echo $param_file $param_key $param_value

}

write_mk_file
