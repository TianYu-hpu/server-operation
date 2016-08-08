# nginx + tomcat 负载均衡
## 负载均衡实现  
反向代理:  
![nginx反向代理](http://7xp6n9.com1.z0.glb.clouddn.com/nginxreverseproxy.png)  
	
	#反向代理设置
	location / {
		//将请求转发给192.168.0.62这个tomcat服务器
		proxy_pass http://192.168.0.62:8080;
	}

![负载均衡](http://7xp6n9.com1.z0.glb.clouddn.com/fuzaijunheng.png)

	#创建后端服务器组,tomcats可以用户自定义
	upstream tomcats{
		#负载均衡策略
		#none 轮询(权重有weight决定)
		#ip_hash   根据客户端请求iphash来进行轮询，每个客户请求的地址在整个回话期间是不变的，因此所对应的后端服务器一般来说是不会变的 在server的upstream里面加一个ip_hash就可以使用了
		----横线以上是nginx内置的轮询策略，后面讲的是第三方的轮询策略
		#fair  自己去管理后端服务器权重，根据后端服务器负载来分配请求 
		#url_hash 通过请求的url来进行hash,指定的url所分配的后端服务器时固定的
		ip_hash
		server 192.168.1.62:8080;
		server 192.168.1.63:8080;

		#weight 权重，值越高，负载越大
		
		#backup 备份机，只有非备份机都挂掉了才启用
		
		#down: 停机标志，不会发送请求到这个服务器，维护使用
		
		#max_fails:达到指定次数认为服务器挂掉
		#fail_timeout:挂掉之后多久再去测试是否已恢复
		server 192.168.1.66 max_fails=2 fail_timeout=60s
	}

	#负载均衡反向代理设置
	
	server {
		location / {
			//将请求转发给192.168.0.62这个tomcat服务器
			proxy_pass http://tomcats;
		}
	}
### 安装第三方负载均衡模块:fair
下载第三方模块，nginx-upstream-fair-master.zip
将这个模块编译进nginx里面

	./configure --prefix=/opt/nginx --add-module=/tmp/nginx-upstream-fair-master

如果已经安装过了，就用make明恋个，就不会替换掉之前安装好的文件，然后到objs找nginx可执行文件，将这个可执行文件放在之前安装好的nginx目录下，替换前先停止nginx服务 nginx -s stop命令  
	
	make
	

##  Session处理策略
1. ip_hash
2. session复制  
所有session都放在tomcat中一份，缺点:每个tomcat中都存放一份，性能低下  
### 实现session复制  
  1.在tomcat server.xml中开启session复制的选项  
在Engine模块中打开Cluster注释，代表打开tomcat的集群功能

	<!-- 基于网络广播的策略，一个节点session变化，其它节点同步复制，节点多或数据量大时性能低下 -->
	  <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster">
	    <Channel className="org.apache.catalina.tribes.group.GroupChannel">  
			#指定接受者，加入两个tomcat的接收器都在一个tomcat上，那么两个tomcat使用的接收器端口是一样的，那么这个时候就会产生端口冲突，通常来说，服务器有多块网卡，因此让接收器绑定内网网卡 
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"  
                      #address="192.168.0.10"
					  address="auto"  
                      port="4000"  /> 
		</Channel>
	  </Cluster>
  2.在应用里面指定该应用处于分布式应用下
  在web.xml中加一个选项告诉应用我在一个集群环境中工作
	<distributable/>
### 在共享空间里面获取session  
基于高速缓存来实现session共享，可以使用redis，memcached这样的缓存来实现，memcached依赖libevent这个库，编译安装和平常的软件安装时一样的
./configure --prefix --with-libevent=/opt/libevent
启动memcached
	#-d后台进程 -u 用户 -p 端口 -c连接数
	memcached -d -u root -p 11211 -c 1024
原理:  
两种模式：  
粘性session:将用户的每次请求都固定在同一个后端服务器  

非粘性session，将用户session分配到任意一个后台服务器  
需要jar包，官方文档有下载链接  
*. spymemcached.jar包  
*. memchached-session-manager-version.jar  
*. memcached-session-manager-tc(tomcat-version)-version.jartomcat版本相关的包  
*. 序列化工具包，有多种可选方案，不设置时使用jdk自带序列化，其它可选kryo，javolution,xstream,flexjson等	
msm-{tools}-serializer-{version}.jar
其它序列化工具相关包  一般第三方序列化工具不需要实现serializable接口 
2. 配置Context，加入处理session的Manager  MemcachedBackupSessionManager  
Context配置查找顺序：  
1）conf/context.xml 全局配置，作用于所有应用  
2) conf/[enginename]/[hostname]/context.xml.default 全局配置，作用于指定host下全部应用  
3) conf/[enginename]/[hostname]/[contextpath].xml 只作用于contextpath指定的应用  
4) 应用META-INF/context.xml 只作用于本应用  
5) conf/server.xml <Host>下 作用于Context docBase指定的应用  
   所以，只希望session管理作用于特定应用，最好用3，4方式设置，希望作用全体，可用1，2，5设置

3. MemcachedBackupSessionManager参数设置，参见context.xml

	<?xml version="1.0" encoding="UTF-8"?>

<Context>

    <WatchedResource>WEB-INF/web.xml</WatchedResource>
    <WatchedResource>${catalina.base}/conf/web.xml</WatchedResource>

	<!-- sticky session 最小配置-->
	<!-- className 管理器类名 -->
	<!-- memcachedNodes memcached服务器节点，以节点名：主机：端口形式表示，其中节点名随意命名，但不同tomcat间要一致 -->
	<!-- sticky隐含默认值为true,此时为sticky session模式 -->
	<!-- failoverNodes 仅适用于sticky模式， n1表示主要将session备份到n2,如果n2不可用，再用n1-->
	<!-- 另一台服务器配置正好相反，这样保证将session保存到其它机器，避免整个机器崩溃时tomcat与session一起崩溃-->
	<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
		memcachedNodes="n1:192.168.1.62:11211,n2:192.168.1.63:11211"
		failoverNodes="n1"
	/>
	
	<!-- 经常用到的生产环境sticky模式配置 -->
	<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
		memcachedNodes="n1:192.168.1.62:11211,n2:192.168.1.63:11211"
		failoverNodes="n1"
		requestUriIgnorePattern=".*\.(jpg|png|css|js)$" 
		memcachedProtocol="binary"
		transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
	/>
	
	<!-- 经常用到的生产环境non-sticky模式配置 -->
	<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
		memcachedNodes="n1:192.168.1.62:11211,n2:192.168.1.63:11211"
		sticky="false"
		sessionBackupAsync="false"
		lockingMode="auto"
		requestUriIgnorePattern=".*\.(jpg|png|css|js)$" 
		memcachedProtocol="binary"
		transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
	/>
	
	<!--
	<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
		memcachedNodes="n1:192.168.1.62:11211,n2:192.168.1.63:11211"
		
		#sticky模式，默认true
		sticky="false"
		
		#仅适用于sticky模式，n1表示主要将session备份到n2,如果n2不可用，再用n1
		failoverNodes="n1"
		
		#忽略的请求类型，这些类型请求不处理session
		requestUriIgnorePattern=".*\.(jpg|png|css|js)$" 
		
		#例如context中设置sessionPath=/时，一个host下多个应用可能有相同session_id，
		#此时向memcached写入时会造成混乱，可通过以下方式加前缀区分不同应用
		storageKeyPrefix="static:name|context|host|webappVersion|context.hash|host.hash|多项组合，以,间隔"
		
		#设置mecached协议数据传输方式，默认text，设为binary有助力性能提升
		memcachedProtocol="binary"
		
		#是否异步存储session变化，默认true，性能好，适用于sticky模式，
		#non-sticky时建议设置为false，避免延迟造成信息不一致
		sessionBackupAsync="false"
		
		#仅适用于non-sticky模式，为避免同步编辑冲突，在修改session时锁定
		#同步编辑一种可能发生的情况是在ajax请求时，同一页多个请求同时发起，可能会访问不同后端
		#auto 读模式不锁写模式锁
		#uriPattern模式，将URI+"?"+queryString与模式Regex匹配，如果匹配则锁定
		lockingMode="none|all|auto|uriPattern:Regex"
		
		#使用第三方序列化工具，提高序列化性能
		#常用的第三方工具kryo, javolution, xstream等
		#此时需要向tomcat/lib下添加相关jar包
		transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
		
	/>
	-->
   
</Context>
3. session
## 集群环境中应用代码注意问题