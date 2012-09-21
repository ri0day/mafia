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
send_node_script_abs_filename="/tmp/process.script"

echo>/tmp/data_recv.dat
mkdir -p $data_store_dir >/dev/null 2>&1

listener_bind="$(/sbin/ifconfig $interface |sed -n '/inet addr:/p'|awk '{print $2}')"
ip=${listener_bind#*:}
$NC -l $ip $data_recv_port >$data_store_dir/$data_store_file &
$NC -l $command_recv_port|while read command
do
	if [ $command == "script" ]
	then
	chmod +x $send_node_script_abs_filename
	echo "$send_node_script_abs_filename $data_store_dir/$data_store_file >$data_store_dir/script_process_result.txt" >/tmp/run_script.txt
	sleep $(cat /dev/urandom| tr -dc '0-9' | fold -w 1| head -n 1)
	$send_node_script_abs_filename $data_store_dir/$data_store_file >$data_store_dir/script_process_result.txt
	cat $data_store_dir/script_process_result.txt |$NC  $gathering_ip $gathering_port
	else
	sleep $(cat /dev/urandom| tr -dc '0-9' | fold -w 1| head -n 1)
	eval "$command" $data_store_dir/$data_store_file |$NC  $gathering_ip $gathering_port
	echo "$command $data_store_dir/$data_store_file |$NC  $gathering_ip $gathering_port" >/tmp/run_command.txt
fi
done
