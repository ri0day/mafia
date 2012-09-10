mafia
=====

###simple bash distribute compute framework 
=====
###运行环境要求:  
* 主控程序所在机器需要与其他节点做ssh信任.用rsa证书自动登录.也就是登录时候不需要交互式输入密码  
* 需要将node.sh放到运算节点上并且有执行权限.  
* 程序默认使用了 1083 1804 5230 端口,需要在节点和主控程序

####程序说明:
* mafia.sh   result_recv.sh   node.sh  

* `mafia.sh` 是主控程序,触发任务,(在这个脚本中定义处理的逻辑与决定处理的节点)  
* `result_recv.sh` 是接收其他节点处理完成后的数据  
* `node.sh` 节点运算的脚本.就是从主控节点接收数据与命令.然后使用主控传过来的命令处理接收到的数据.最后返回给result_recv.sh所在节点

###使用步骤:
 * host7-1 host7-2 是运算节点.`将node.sh 脚本放到2台机器的/tmp目录下  `
 * host5-7 是result_recv.sh 节点 与主控程序. `将mafia.sh 与result_recv.sh 放到/tmp 目录`    
 * 启动result_recv.sh (`后台模式`)    
 * 执行测试命令 (`由于awk 里有需要转义的特殊符,所以需要转义`) ,测试文件是 /etc/passwd copy 到 /tmp/da的

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
