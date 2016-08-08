#Nginx安装    
## 一、linux安装软件的方式:    

1. rpm/dpkg安装    
1、使用的是通用的参数变异，配置参数不是最佳    
2、可控制性不强，比如对程序特定组件的定制安装    
3、通常安装包间有复杂的依赖关系，操作比较复杂    
4、安装简单，出错几率低    

2. yum    
改良版的rpm，自动下载安装包，自动管理依赖关系    
3. 编译安装    
1、可控性强，config时可根据当前环境优化参数，可定制组件以及安装参数    
2、易出错，难度高    
## 编译安装  
1. 检查和安装依赖项    

    `yum -y install gcc pcre pcre-devel zlib zlib-devel openssl openssl-devel `   
2. configure    
configure 支持很多参数化的配置，通过--help查看帮助文档，实际安装的时候通过--prefix指定安装目录
3. make && make install   
4. 启动、重启    
启动    

	`./nginx`    
修改配置参数重启    

	`./nginx -s reload`    
测试配置文件是否正确    

	`./nginx -t`    
开机启动，vim /etc/rc.d/rc.local文件，将启动命令放在对应的位置目录就可以了        

	`/usr/local/nginx/sbin/nginx`
#Nginx配置   
nginx配置文件conf/nginx.conf,配置文件按模块化进行区分，每个模块以模块名 + 大括号来命名，内部配置采用分号分隔  

    #顶层配置信息管理服务器级别行为
    #工作进程数
    worker_precesses 1;
    
    #event指令与事件模型有关。配置处理连接有关信息
    events {
     	#工作线程最大可连接数
		work_connections 1024;
	}
    
    #http指令处理http请求
    http {
    	#mime type映射，当请求的文件是html时会从这个文件里获取html的mime类型，然后返回给浏览器，如果有特殊的mime类型的话徐璈添加到这个文件中
  		#include 引入另一个文件
        include mime.types;
		#如果请求文件的mime类型不存在的时候使用的默认的mime类型，采用二进制流的形式
        default_type application/octet-stream;
    
		sendfile on;
		#tcp_nopush on;
			
		#启用gzip压缩
		gzip on;

		#连接超时时间
		keepaalive_timeout 0;

		#sever 表示一个虚拟主机，一台服务器可配置多个虚拟主机
		server {
			#监听端口
			listen 80;
			#识别的域名或地址，一个http模块中可以配置多个server，那么到底交个哪个server呢，由server_name来决定，当所有都不匹配的时候，默认匹配第一个，localhost可以匹配localhost的域名也可以匹配其他的
			server_name localhost;

			#url参数编码，解决url参数乱码
			charset utf-8;

			#访问日志文件，由于需要进行读写操作，当考虑性能时可以不开启访问日志功能
			access_log logs/host.access.log main;
			
			#匹配模式
			#当一个请求到达时，比如index.html，当收到这个文件请求时，把这个请求返回给浏览器，另一种情况是nginx同时作为一种反向代理服务器，当nginx收到这个请求hour，把这个请求发送给后端服务器，然后将后端服务器响应的结果返回给浏览器，本身充当一个代理者的角色
			
			#syntax:location [=|~|~*|^~|@] /uri/ {...}    
			#分为两种匹配模式，普通字符串匹配，正则匹配    
			#无开头引导字符或以=开头表示普通字符串匹配    
			#以~或~*开头表示正则匹配，~*表示不区分大小写
			#以^~开头表示不正则匹配
			#@变量定义
			#多个location时匹配规则 
			#总是先普通后正则原则，只是别URI部分，例如请求为/test/1/abc.do?arg=xxx
			#1. 先找是否有=开头的精确匹配，即location=/test/1/abc.do {...}
			#2. 再查找普通匹配，以 最大前缀 为规则，如有以下两个location
			#    location /test/ {...}
			#    location /test/1/ {...}
			#则匹配最后一项
			#3. 匹配到一个普通个时候，搜索并未结束，而是暂存当前结果，继续索索正则匹配
			#4. 在所有正则模式中location中找到第一个匹配项后，就作为最终匹配结果
			#所以正则匹配项匹配规则定义前后顺序影响，但普通匹配不会
			#5. 如果未找到正则匹配，则以3中的结果作为最终结果
			
			#location =/ {...} 与 location / {...}差别
			#前一个是精确匹配，只响应/请求，所有/xxx请求不会以前缀匹配形式匹配到它
			#后一个正好相反，所有请求都以/开头，所有没有其他陪陪结果是一定会执行它，这也是默认的配置
			location {
				#location表达式:有两层含义，当收到请求时怎么处理，另一种当收到请求时它的处理行为时什么
				#处理行为
				#第一种：在本地系统root路径找文件，如果请求没有指定文件名例如/则在root路径中找index文件
				#第二种，不是在本地系统找文件，就是通过代理找文件
				#系统的跟路径在哪里，可以是绝对路径也可以是相对路径
				root html;
				#index
				index index.html index.htm;
				
				#决绝所有请求返回403
				#deny all;

				#默认允许所有
				allow all;
			}  

			location ~ \.jsp$ {
				#处理代理
				proxy_pass http://192.168.0.110:8080;
			}
			
			#错误页
			error_page 404      /404.html; 

			#指向错误页到静态的/50x.html
			error_page 500 502 503 504 /50x.html;
			location = /50x.html {
				root html;
			}

			#@类似于变量定义
			#error_page 403 http://www.baidu.com这种定义不允许，利用@实现
			error_page 403 @page403;
			location @page403 {
				proxy_pass http://www.baidu.com
			}
		}
    }


#Nginx优化    
	
	#nginx 在安装完成后，大部分参数已经是最优化了，我们需要管理的东西不多
	user nobody;
	
	#阻塞和非阻塞网络模型
	#同步阻塞模型 一请求一线程，当线程增加到一定程度后，更多CPU时间浪费到切换线程，性能急剧下降，所以负载率不高
	#nginx基于事件的非阻塞多路复用(epoll或kquene)模型，一个进程在短时间内可以相应大量的请求
	#建议值 <= cpu 核心数量，一般高于cpu数量不会带来好处；也许还要进程间切换的开销
	worker_processes 4;

	#将worker_process绑定到特定的cpu上，避免进程在cpu间切换的开销
	worker_cpu_affinity 0001 0010 0100 1000
	#8核4进程设置方法
	#worker_cpu_affinity 00000001 00000010 00000100 10000000

	#每进程最大可打开文件描述付数量(linux文件描述符包含网络端口，设备，文件等)
	#文件描述符用完了，新的连接就会拒绝，产生502错误
	#linux最大文件数可通过ulimit -n FILECNT 或/etc/security/limits/conf配置
	#理论值 系统最大数量 / 进程数，但进程间工作量并不是平均分配的，所以开一设置大一些
	worker_rlimit_nofile 655350;

	#error_log logs/error.log;
	#error_log logs/error.log notice;
	#error_log logs/error.log info;
	#pid       logs/nginx.pid;

	events {
		#并发响应能力的关键配置值
		#每个进程允许的最大同时连接数， work_connection * worker_processes = maxConnection;
		#maxConnections不等于可响应的用户数量
		#因为一般一个浏览器会同时开两个连接，如果反向代理，nginx到后端服务器的连接数也要占用连接数，所以做静态服务器时，一般maxClient = work_connection * worker_processes / 2;
		#做反向代理服务器时 maxClient = work_connections * worker_processes / 4;
		#这个值理论上越大于浩，但最多可承受多少请求与配件和网络相关，也和最大可打开文件，最大可用socket数量有关
		work_connections 500;
		worker_connections 200000;

		#指明使用那种网络模型 epoll或者kquene(*BSD)
		use epoll;
	}

	http {
	
		#log_format main '$remote_addr - $remote_user [$time_local] "$request"'
					     '$status $body_bytes_sent "$http_referer"'
					     '"$http_user_agent" "$http_x_forwarded_for"';
		
		#关闭此项开减少IO开销，但是无法记录访问信息，不利于业务分析，一般运维情况不建议使用
		#access_log off; 

		#只记录更为验证的错误日志，可减少IO压力
		error_log logs/error.log crit;

		#启用内核复制模式，应该保持开启达到最快IO效率
		sendfile on;

		#以下两项配置，会在数据包达到一定大小后发送数据，这样会减少网络通讯次数，降低阻塞概率，但也会影响响应及时性，比较适合于文件下载这类的大数据包通信场景
		tcp_push on;
		tcp_nodelay on|off on禁用Nagle算法

		#降低每个连接的alive时间可在一定程度上提高可响应连接数量，所以一般可适当降低此值
		#keepalive_timeout 30s;

		#启动内容压缩，有效降低网络流量
		gzip on;
		#过短的内容压缩压小不佳，压缩过程还会浪费系统资源
		gzip_min_length 1000;
		#可选值1-9，压缩机别越高压缩率越高，但对系统性能需求越高
		gzip_comp_level 4;
		#压缩内容级别
		gzip_types text/plain text/css application/json application/x-javascript text/html text/xml application/xml application/xml+rss text/javascript

		#静态文件缓存
		#最大缓存数量，文件未使用存活期
		open_file_cache max = 655350 inactive=20s;

		#验证文件有效期时间间隔
		open_file_cache_valid 30s;
	
		#有效期内文件最少使用次数
		open_file_cache_min_uses 2;
	}

