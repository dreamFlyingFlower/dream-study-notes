#!/bin/bash


################## 1 ##################


# 判断用户输入的是否为IP地址

function check_ip(){
	IP=$1
	VALID_CHECK=$(echo $IP|awk -F. '$1< =255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
	if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then
		if [ $VALID_CHECK == "yes" ]; then
			echo "$IP available."
		else
			echo "$IP not available!"
		fi
	else
		echo "Format error!"
	fi
}


################## 2 ##################


# 判断用户输入的是否为IP地址

function check_ip(){
	IP=$1
	if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		FIELD1=$(echo $IP|cut -d. -f1)
		FIELD2=$(echo $IP|cut -d. -f2)
		FIELD3=$(echo $IP|cut -d. -f3)
		FIELD4=$(echo $IP|cut -d. -f4)
		if [ $FIELD1 -le 255 -a $FIELD2 -le 255 -a $FIELD3 -le 255 -a $FIELD4 -le 255 ]; then
			echo "$IP available."
		else
			echo "$IP not available!"
		fi
	else
		echo "Format error!"
	fi
}


################## 3 ##################


# 判断用户输入的是否为IP地址
function check_ip(){
	local IP=$1
	VALID_CHECK=$(echo $IP|awk -F. '$1< =255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
	if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" >/dev/null; then
		if [ $VALID_CHECK == "yes" ]; then
			return 0
		else
			echo "$IP not available!"
			return 1
		fi
	else
		echo "Format error! Please input again."
		return 1
	fi
}

while true; do
	read -p "Please enter IP: " IP
	check_ip $IP
	[ $? -eq 0 ] && break || continue
done