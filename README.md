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
###���л���Ҫ��:  
* �Ƽ����س������ڻ�����Ҫ�������ڵ���ssh����.��rsa֤���Զ���¼.Ҳ���ǵ�¼ʱ����Ҫ����ʽ�������� ,��Ȼ��Ҳ�����ֶ���������,Ҳ�ǿ��е�.
* ��Ҫ��node.sh�ŵ�����ڵ��ϲ�����ִ��Ȩ��.  
* ����Ĭ��ʹ���� 1083 1804 5230 �˿�,��Ҫ���Ͻڵ�����س������⼸���˿������谭ͨѶ

####����˵��:
* mafia.sh   result_recv.sh   node.sh  include.lib

* `mafia.sh` �����س���,��������,(������ű��ж��崦����߼����������Ľڵ�)  
* `result_recv.sh` �ǽ��������ڵ㴦����ɺ������  
* `node.sh` �ڵ�����Ľű�.���Ǵ����ؽڵ��������������.Ȼ��ʹ�����ش��������������յ�������.��󷵻ظ�result_recv.sh���ڽڵ�
* `include.lib` ���س����߼���������.


###ʹ�ò���(command mode):
 * host7-1 host7-2 ������ڵ�.`��node.sh �ű��ŵ�2̨������/tmpĿ¼��  `
 * host5-7 ��result_recv.sh �ڵ� �����س���. `��mafia.sh ��result_recv.sh �ŵ�/tmp Ŀ¼`    
 * ����result_recv.sh (`��̨ģʽ`)    
 * ִ�в������� (`����awk ������Ҫת��������,������Ҫת��`)   BTW:�����ļ��� /etc/passwd copy �� /tmp/da��

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
####5.�˶�����:
����ڵ�  
```
[root@host7-1 tmp]# grep "nologin" data_recv.dat |wc -l
14
[root@host7-2 tmp]# grep "nologin" data_recv.dat |wc -l
14
```
result_recv �ڵ�
```
[root@host5-7 opt]# wc -l result_data_recv.dat 
28 result_data_recv.dat
```

###script mode

#####script mode��Ҫʹ���ض���command�ؼ���"script"�Լ�Ҫָ�� script�ľ���··��

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

�������:
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