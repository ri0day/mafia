#!/bin/bash
. include.lib
data_recv_port=1083
command_recv_port=1084
data_store_dir="/tmp/da"
data_store_file="data_recv.dat"
interface="eth0"
gathering_ip="10.0.5.7"
gathering_port="5230"
NC="$(which nc)"
debug=1
username="wumin"
node_handler_file="/tmp/node.sh"

if [ $# -ne 6  ]
then
	usage
	exit
else
:
fi

while getopts h:c:f: OPTIONS
do
        case $OPTIONS in
        h) declare -a node_list=($OPTARG);;
        c) command=$OPTARG;;
        f) raw_data_file=$OPTARG;;
        esac
done


local_check

if [ $debug -eq 1 ]
then
        echo "node_list is :${node_list[*]}"
        echo "command is $command"
        echo "raw_data_file is $raw_data_file"
else
        :
fi


node_is_live "`echo ${node_list[*]}`"
check_environ_requirement
split_raw_file $raw_data_file
start_nodes
send_data_to_nodes
send_commnad_to_nodes
