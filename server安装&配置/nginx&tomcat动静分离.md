# 动静分离
考虑到项目中静态页面访问服务器基本上都是采用接口的形式来进行访问，并且为了级别更加清晰将动态服务器和静态服务器进行分离。主要的配置信息都在nginx这块。  

	user nobody;
    worker_processes  8;

    error_log /usr/local/nginx/logs/nginx_error.log crit;
    
    pid logs/nginx.pid;

    worker_rlimit_nofile 655350;

	include mime.types;
    default_type application/octet-stream;

    #charset utf8;

    server_names_hash_bucket_size 128;  
    client_header_buffer_size 32k;  
    large_client_header_buffers 4 32k;  
    client_max_body_size 8m;

    sendfile        on;
    tcp_nopush     on;

    keepalive_timeout  60;

    tcp_nodelay on;  

    fastcgi_connect_timeout 300;  
    fastcgi_send_timeout 300;  
    fastcgi_read_timeout 300;  
    fastcgi_buffer_size 64k;  
    fastcgi_buffers 4 64k;  
    fastcgi_busy_buffers_size 128k;  
    fastcgi_temp_file_write_size 128k;  

    gzip on;  
    gzip_min_length  1k;  
    gzip_buffers     4 16k;  
    gzip_http_version 1.0;  
    gzip_comp_level 2;  
    gzip_types  text/plain application/x-javascript text/css application/xml;  
    gzip_vary on;  

    #limit_zone  crawler  $binary_remote_addr  10m;

    events {
		#网络模型
        use epoll;
        worker_connections  65535;
    }

	upstream tomcat_server {
		#tomcat 服务器地址  
        server 192.167.20.30:8080;  
    }  
      
    server {  
        listen       80;  
        server_name  localhost;  
        root  D:\work_web;  
          
        location / {  
            index index.jsp;  
        } 
 
        location /j_spring_security_check {  
            proxy_set_header Host $host;  
            proxy_set_header X-Forwarded-For $remote_addr;  
            proxy_pass http://tomcat_server;  
        }  

        location ~ .*\.(jsp|do}action)$ {            
            proxy_set_header Host $host;  
            #将请求nginx请求的用户主机地址发送给tomcat
			proxy_set_header X-Forwarded-For $remote_addr;
			#反向代理到tomcat  
            proxy_pass http://tomcat_server;  
			proxy_redirect off;  
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
            client_max_body_size 10m;  
            client_body_buffer_size 128k;  
            proxy_connect_timeout 90;  
            proxy_send_timeout 90;  
            proxy_read_timeout 90;  
            proxy_buffer_size 4k;  
            proxy_buffers 4 32k;  
            proxy_busy_buffers_size 64k;  
            proxy_temp_file_write_size 64k;  
        }  
          
        location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|js|css|html)$ #设定访问静态文件直接读取不经过tomcat  {  
			#expires定义用户浏览器缓存的时间为7天，如果静态页面不常更新，可以设置更长，这样可以节省带宽和缓解服务器的压力
            expires      30d;  
        }  
        location ~ ^/(WEB-INF)/ { #这个很重要，不然用户就可以访问了  
            deny all;  
        }  
		
		#错误页面定位到 根目录下的 50x.html这个文件
        error_page   500 502 503 504  /50x.html;  
		
        location = /50x.html {  
            root   html;  
        }  
    }  