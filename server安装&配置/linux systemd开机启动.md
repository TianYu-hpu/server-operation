# 添加自定义系统服务  
Centos 系统服务脚本目录  

	/usr/lib/systemd/
有系统(system)和用户(user)之分  
如果需要开机没有登录情况加就能运行程序，存在系统服务里面，既

	/lib/systemd/system/
反之，用户登录后才能运行的程序，存在用户(user)里，服务以.service结尾  

以nginx为例进行开机启动

vim /lib/systemd/system/nginx.service 

	[Unit]  
	Description=nginx  
	After=network.target  
   
	[Service]  
	Type=forking  
	ExecStart=/www/lanmps/init.d/nginx start  
	ExecReload=/www/lanmps/init.d/nginx restart  
	ExecStop=/www/lanmps/init.d/nginx  stop  
	PrivateTmp=true  
   
	[Install]  
	WantedBy=multi-user.target  

