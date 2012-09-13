mafia
=====

###simple bash distribute compute framework 


###==What it do==
* split you data by number of nodes ,send every pieces of data to  node, and process data by you specifed command or script .finally, send the result back

###==Requirements==
 * bash
 * linux command: nc ,cat ,ifconfig ,ssh

###==role define==   
* controler  
* nodes   
* recevier  
#####controler: mafia.sh , the main componet of framewoker ,the script receive argument from user input ,parse argument,define global variable ,communication with nodes
#####nodes: node.sh ,the script recevie data and command from controler, handler data by specified command or script ,send the result to receiver.  
#####receiver: result_recv.sh ,the script receive result from nodes.  

###==quick start==   
make sure login to node without input passwd
```
[root@controler]# ssh-keygen -t rsa
[root@controler]# ssh-copy-id ~/.ssh/id_rsa.pub username@node[1-2]
```
1.put node.sh on node server /tmp/node.sh and grant execute permission
```
[root@node1]#chmod+x /tmp/node.sh
[root@node2]#chmod+x /tmp/node.sh
```
2.run result_recv.sh in background on controler
```
[root@controler]# ./result_recv.sh & (background mode)
```
3.prepare data for test
```
[root@controler]# mkdir -/tmp/da
[root@controler]# cp -a /etc/passwd /tmp/da/passwd
```
4.run test
command mode:
```
[root@controler]#./mafia.sh -h "node1 node2" -f /tmp/da/passwd -c "awk -F\"/\" '\$NF ~ /nologin/{print \$0}'"
```
script mode:
```
[root@controler]#./mafia.sh -h "10.0.7.1 10.0.7.2" -f /tmp/da/passwd -c script -s /tmp/s.py

[root@controler ~]# cat /tmp/s.py 
#!/usr/bin/python
import sys
filename=sys.argv[1]
f = open(filename,'r').readlines()
for x in f:
        shell=x.split(":")[-1].strip()
        if shell == "/sbin/nologin":
                print "%s:%s"%(x.split(":")[0],shell)
```

 =====
###运行环境要求:  
* 推荐主控程序所在机器需要与其他节点做ssh信任.用rsa证书自动登录.也就是登录时候不需要交互式输入密码 ,当然你也可以手动输入密码,也是可行的.
* 需要将node.sh放到运算节点上并且有执行权限.  
* 程序默认使用了 1083 1804 5230 端口,需要保障节点和主控程序在这几个端口上无阻碍通讯

####程序说明:
* mafia.sh   result_recv.sh   node.sh  include.lib

* `mafia.sh` 是主控程序,触发任务,(在这个脚本中定义处理的逻辑与决定处理的节点)  
* `result_recv.sh` 是接收其他节点处理完成后的数据  
* `node.sh` 节点运算的脚本.就是从主控节点接收数据与命令.然后使用主控传过来的命令处理接收到的数据.最后返回给result_recv.sh所在节点
* `include.lib` 主控程序逻辑函数集合.


###使用步骤(command mode):
 * host7-1 host7-2 是运算节点.`将node.sh 脚本放到2台机器的/tmp目录下  `
 * host5-7 是result_recv.sh 节点 与主控程序. `将mafia.sh 与result_recv.sh 放到/tmp 目录`    
 * 启动result_recv.sh (`后台模式`)    
 * 执行测试命令 (`由于awk 里有需要转义的特殊符,所以需要转义`)   BTW:测试文件是 /etc/passwd copy 到 /tmp/da的

```
[root@host5-7 tmp]# ./mafia.sh -h "10.0.7.1 10.0.7.2" -f /tmp/da/passwd -c "awk -F\"/\" '\$NF ~ /nologin/{print \$0}'"
node_list is :10.0.7.1 10.0.7.2
command is awk -F"/" '$NF ~ /nologin/{print $0}'
raw_data_file is /tmp/da/passwd


2
cat /tmp/da/passwd00 |/usr/bin/nc 10.0.7.1 1083
cat /tmp/da/passwd01 |/usr/bin/nc 10.0.7.2 1083
awk -F: \'$1 ~/root/{print $0}\'|/usr/bin/nc 10.0.7.1 1084
awk -F: \'$1 ~/root/{print $0}\'|/usr/bin/nc 10.0.7.2 1084
```
####5.核对数据:
运算节点  
```
[root@host7-1 tmp]# grep "nologin" data_recv.dat |wc -l
14
[root@host7-2 tmp]# grep "nologin" data_recv.dat |wc -l
14
```
result_recv 节点
```
[root@host5-7 opt]# wc -l result_data_recv.dat 
28 result_data_recv.dat
```

###script mode

#####script mode需要使用特定的command关键字"script"以及要指定 script的绝对路路径

```
[root@host5-7 tmp]# ./mafia.sh -h "10.0.7.1 10.0.7.2" -f /tmp/da/passwd -c script -s /tmp/s.py 
```

```
[root@host5-7 tmp]# cat s.py 
#!/usr/bin/python
import sys

filename=sys.argv[1]

f = open(filename,'r').readlines()
for x in f:
        shell=x.split(":")[-1].strip()
        if shell == "/sbin/nologin":
                print "%s:%s"%(x.split(":")[0],shell)
```

检查数据:
```
[root@host5-7 tmp]# cat /opt/result_data_recv.dat 
bin:/sbin/nologin
daemon:/sbin/nologin
adm:/sbin/nologin
lp:/sbin/nologin
mail:/sbin/nologin
uucp:/sbin/nologin
operator:/sbin/nologin
games:/sbin/nologin
gopher:/sbin/nologin
ftp:/sbin/nologin
nobody:/sbin/nologin
vcsa:/sbin/nologin
dbus:/sbin/nologin
sshd:/sbin/nologin
haldaemon:/sbin/nologin
rpc:/sbin/nologin
apache:/sbin/nologin
avahi:/sbin/nologin
mailnull:/sbin/nologin
smmsp:/sbin/nologin
rpcuser:/sbin/nologin
nfsnobody:/sbin/nologin
oprofile:/sbin/nologin
pcap:/sbin/nologin
ntp:/sbin/nologin
xfs:/sbin/nologin
avahi-autoipd:/sbin/nologin
sabayon:/sbin/nologin
```