#!/bin/bash
data_recv_port=1083
command_recv_port=1084
data_store_dir="/opt"
data_store_file="result_data_recv.dat"
interface="eth0"
gathering_ip="10.0.5.7"
gathering_port="5230"
NC="/usr/bin/nc"
debug=1

mkdir -p $data_store_dir >/dev/null 2>&1

listener_bind="$(/sbin/ifconfig $interface |sed -n '/inet addr:/p'|awk '{print $2}')"
ip=${listener_bind#*:}
while true
do
$NC -l $gathering_ip $gathering_port |while read result
do
echo $result >>$data_store_dir/$data_store_file
done
done
