mafia
=====

###simple bash distribute compute framework 
=====
###���л���Ҫ��:  
* ���س������ڻ�����Ҫ�������ڵ���ssh����.��rsa֤���Զ���¼.Ҳ���ǵ�¼ʱ����Ҫ����ʽ��������  
* ��Ҫ��node.sh�ŵ�����ڵ��ϲ�����ִ��Ȩ��.  
* ����Ĭ��ʹ���� 1083 1804 5230 �˿�,��Ҫ�ڽڵ�����س���

####����˵��:
* mafia.sh   result_recv.sh   node.sh  

* `mafia.sh` �����س���,��������,(������ű��ж��崦����߼����������Ľڵ�)  
* `result_recv.sh` �ǽ��������ڵ㴦����ɺ������  
* `node.sh` �ڵ�����Ľű�.���Ǵ����ؽڵ��������������.Ȼ��ʹ�����ش��������������յ�������.��󷵻ظ�result_recv.sh���ڽڵ�

###ʹ�ò���:
 * host7-1 host7-2 ������ڵ�.`��node.sh �ű��ŵ�2̨������/tmpĿ¼��  `
 * host5-7 ��result_recv.sh �ڵ� �����س���. `��mafia.sh ��result_recv.sh �ŵ�/tmp Ŀ¼`    
 * ����result_recv.sh (`��̨ģʽ`)    
 * ִ�в������� (`����awk ������Ҫת��������,������Ҫת��`) ,�����ļ��� /etc/passwd copy �� /tmp/da��

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
