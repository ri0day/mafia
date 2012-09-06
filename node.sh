#!/bin/bash

data_recv_port=1083
command_recv_port=1084
data_store_dir="/tmp"
data_store_file="data_recv.dat"
interface="eth0"
gathering_ip="10.0.5.7"
gathering_port="5230"
NC="/usr/bin/nc"
debug=1

echo>/tmp/data_recv.dat
echo>debug.log

listener_bind="$(/sbin/ifconfig $interface |sed -n '/inet addr:/p'|awk '{print $2}')"
ip=${listener_bind#*:}
$NC -l $ip $data_recv_port >$data_store_dir/$data_store_file &
$NC -l $command_recv_port|while read command
do
	echo "start listen" >/tmp/debug.log
	[ $debug -eq 1 ]&&echo "$command executed"||:	
	eval "$command" $data_store_dir/$data_store_file |$NC  $gathering_ip $gathering_port
	echo "$command $data_store_dir/$data_store_file |$NC  $gathering_ip $gathering_port" >/tmp/1.txt
done&
