# 安装
1. 安装JDk    
配置环境变量，vim /etc/profile.d/java.sh在这里设置环境变量    
    
		JAVA_HOME=/opt/jdk1.8.0_51
		PATH=$JAVA_HOME/bin:$PATH
		export JAVA_HOME PATH

执行sources /etc/profile.d/java.sh来更新环境变量
2. 安装Tomcat    
下载tar.gz格式直接解压使用，启动后看控制台输出信息到catalina.out  
开机运行
开机运行之前首先让Java开机运行，我们在rc.local文件夹中加入

	#由于rc.local启动的时间是早于profile.d文件夹下的环境变量的配置，因此需要在这里再次配置java环境变量
	JAVA_HOME=/opt/jdk1.8.0_51
	#启动JAVA
	$TOMCAT_HOME/bin/startup.sh
# 配置
内存使用配置:JVM使用内存大小  
JVM参数在catalina.sh文件里面，
	
	# windows下设置方法
	#set JAVA_OPTS=%JAVA_OPTS% -server -Xms512m -Xmx512m -XX:PermSize=512M -XX:MaxPermSize=512m 
	# 通过内存设置充分利用服务器内存
	# -server模式启动应用慢，但可以极大程度提高运行性能
	# java8开始，PermSize被MetaspaceSize代替，MetaspaceSize共享heap，不会再有java.lang.OutOfMemoryError: PermGen space，可以不设置
	# headless=true适用于linux系统，与图形操作有关，如生成验证码，含义是当前使用的是无显示器的服务器，应用中如果获取系统显示有关参数会抛异常
	# 可通过jmap -heap proccess_id查看设置是否成功
	JAVA_OPTS=$JAVA_OPTS  -server -Xms2048m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m -Djava.awt.headless=true 

最大连接数在server.xml中配置

	<!-- protocol 启用 nio模式，(tomcat8默认使用的是nio)(apr模式利用系统级异步io) -->
	<!-- minProcessors最小空闲连接线程数-->
	<!-- maxProcessors最大连接线程数-->
	<!-- acceptCount允许的最大连接数，应大于等于maxProcessors-->
	<!-- enableLookups 如果为true,requst.getRemoteHost会执行DNS查找，反向解析ip对应域名或主机名-->
	<Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol" 
		connectionTimeout="20000"
        redirectPort="8443
		
		maxThreads=“500” 
		minSpareThreads=“100” 
		maxSpareThreads=“200”
		acceptCount="200"
		enableLookups="false"		
	/>  
# 优化