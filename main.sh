#!/bin/bash
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

listener_bind="$(/sbin/ifconfig $interface |sed -n '/inet addr:/p'|awk '{print $2}')"
ip=${listener_bind#*:}


while getopts h:c:f: OPTIONS
do
	case $OPTIONS in
	h) declare -a node_list=($OPTARG);;
	c) command=$OPTARG;; 
	f) raw_data_file=$OPTARG;;
	esac
done

if [ $debug -eq 1 ]
then
	echo "node_list is :${node_list[*]}"
	echo "command is $command"
	echo "raw_data_file is $raw_data_file"
else
	:
fi

node_is_live() {
idx=0
declare -a nodes=($1)
for nd in ${nodes[@]}
do
	((idx++))
if ping -c 1 -W 1 $nd 1>/dev/null 2>&1
	then
	echo
else
	echo "node: $nd conection fail,will be ignored"
	unset node_list[idx-1]
fi
done
}

node_is_live "`echo ${node_list[*]}`"


check_environ_requirement() {
#remote file exist

client_idx=0
for client in ${node_list[@]}
do	
	((client_idx++))
	file_exist_and_executable=$(ssh $username@$client "[ -x "$node_hander_file" ]&&echo ok||echo fail")
	client_port_available=$(ssh $username@$client "if /bin/netstat -nalt|grep 1080[3-4] 1>/dev/null 2>&1;then echo unavailabe;else echo availabe;fi" )
	if [ "$file_exist_and_executable" == "ok" -a "$client_port_available" == "availabe" ]
	then
	:
	else
#	echo "$node_hander_file can't be executed or not found on node $client ,will be ignored"
	echo "$node_hander_file can't be executed or not found on node $client, or client port unavailabe."
	unset node_list[client_idx-1]
	fi
done
}

check_environ_requirement


	



split_raw_file() {
cd $data_store_dir
line=$(wc -l $1)
pices=${#node_list[@]}
echo $pices
if [ $pices -eq 1 ]
then
	mv "$1"  $1"00"
else
        avg=$((${line%%/*}/$pices))
        if [ $(expr ${line%%/*} % $avg) -gt 0 ]
        then
        avg=$(($avg+1))
        else
        :
        fi
        split -d -l $avg $1 ${1%.*}
fi
}

split_raw_file $raw_data_file


# start node ,redirect stdin stderr,close ssh session
for node_idx  in `seq 0 $((${#node_list[@]}-1))`
do
	ssh  $username@${node_list[node_idx]} "sh /tmp/node.sh >/dev/null 2>&1 &"
done

#wait nodes startup
sleep 2s

#send data to node
i=0
for file in $data_store_dir/*0*
do	
	cat $file |$NC ${node_list[i++]} $data_recv_port
	echo "cat $file |$NC ${node_list[i++]} $data_recv_port"
done


#send command to data node
for node in ${node_list[@]}
do
	
	echo "$command"|$NC $node $command_recv_port
	echo "awk -F":" \'\$1 ~/root/{print \$0}\'|$NC $node $command_recv_port"
done
