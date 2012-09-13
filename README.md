mafia
=====

###simple bash distribute compute framework 
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

###script mode:
script mode ��Ҫʹ���ض���command �ؼ���"script" �Լ�Ҫָ�� script�ľ���·��   
-----
./mafia.sh -h "10.0.7.1 10.0.7.2" -f /tmp/da/passwd -c script -s /tmp/s.py   
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