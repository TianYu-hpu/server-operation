##MySQL双机互备配置
###假设A、B、C三台服务器用户进行MySQL集群的配置，A、B两台服务进行双主的配置，B、C两台服务器进行主从的配置
master上安装半同步复制插件
	
	install plugin rpl_semi_sync_master soname 'semisync_master.so';
slave上安装半同步复制插件
	
	install plugin rpl_semi_sync_slave soname 'semisync_slave.so';
A、B两台服务器的 /etc/my.cnf 配置文件参考这个的配置文件

	[mysqld]
	........

	log-error=/var/log/mysqld.log
	pid-file=/var/run/mysqld/mysqld.pid
	#开启慢查询日志功能
	slow_query_log=TRUE
	slow_query_log_file=/var/lib/mysql/slow_query_log.txt
	long_query_time=2
	##从这里开始
	lower_case_table_names=1
	max_allowed_packet = 200M

	#master conf
	server-id=131
	log-bin=mysql-bin
	log-bin-index=mysql-bin.index
	binlog-format=row
	binlog-do-db = softcentric
	binlog-ignore-db = mysql
	binlog-ignore-db=information_schema
	binlog-ignore-db=performance_schema
	relay-log=slave-relay-bin
	relay-log-index=slave-relay-bin.index
	log-slave-updates
	innodb_flush_log_at_trx_commit=1
	sync_binlog = 1
	auto_increment_offset = 1
	auto_increment_increment = 2
	replicate-do-db = softcentric
	replicate-ignore-db = mysql,information_schema,performance_schema
	#半同步复制
	rpl_semi_sync_master_enabled=1
	rpl_semi_sync_slave_enabled=1
	#GTID配置
	#log-bin=master-bin
	#log-slave-updates
	gtid-mode = on
	enforce-gtid-consistency


C数据库服务器的 /etc/my.cnf配置文件参考这个进行配置

	[mysqld]
	.....
	pid-file=/var/run/mysqld/mysqld.pid
	#开启慢查询日志功能
	slow_query_log=TRUE
	slow_query_log_file=/var/lib/mysql/slow_query_log.txt
	long_query_time=2
	lower_case_table_names=1
	max_allowed_packet = 200M
	#slave conf
	server-id=2
	log-bin=mysql-bin
	log-bin-index=mysql-bin.index
	binlog-format=row
	binlog-do-db = softcentric
	binlog-ignore-db = mysql
	binlog-ignore-db=information_schema
	binlog-ignore-db=performance_schema
	log-slave-updates
	relay-log=slave-relay-bin
	relay-log-index=slave-relay-bin.index
	auto_increment_offset = 2
	auto_increment_increment = 2
	#半同步复制
	rpl_semi_sync_master_enabled=1
	rpl_semi_sync_slave_enabled=1
	#GTID配置
	#log-bin=master-bin
	#log-slave-updates
	gtid-mode = on
	enforce-gtid-consistency

这个配置文件修改的地方是server-id后面的数字改成当前电脑的IP地址后缀，例如ip地址格式为A.B.C.D，则这里输入 D 的内容，修改完后重启数据库。
分别在A、B两台服务器上面创建一个repl_user的用户

	create user 'repl_user'@'A.B.C.%' identified by 'Password';

为repl_user用户赋予 replication 的权限

	grant replication slave,replication client on *.* to 'repl_user'@'A.B.C.%';

分别在A、B两台服务器上执行以下命令
	
	change master to master_host='IP地址',master_port=3306,master_user='repl_user',master_password='password', master_auto_position = 1;


	
然后执行启动 slave 线程的命令

	start slave;

查看状态
	
	show slave status\G;

查看半同步状态是否成功
	
	show status like '%Rpl%';

主要看

	Slave_IO_Running
	Slave_SQL_Running
 
两个状态是否为YES，如果都为YES，则证明主从配置正确，否则不正确，当不正确的时候查看mysql 日志报什么错误，一般可以通过以下命令解决 

	stop slave;
	reset slave;
	start slave;
当主主或主从结构配好之后导入数据库到其中的一个主服务器上，然后切换到另外一个主或者从服务器上看数据库是否存在，尝试着创建一些表看另一台从服务器是否存在该表，对应着插入一些测试数据看看是否同步完成。



