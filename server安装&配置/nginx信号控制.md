# nginx 信号控制

## nginx启动与停止  
启动:  

	nginx [-c nginx配置文件地址]
停止  
从容停止:  

	kill -QUIT nginx pid	
快速停止:  

	kill -TERM nginx pid
	kill -INT nginx pid
强制停止:  

    kill -9 nginx pid

重新记载配置文件:  

	nginx -s reload

发送信号重启:  

    kill -HUP nginx pid

测试配置文件是否正确:  

	nginx -t [-c nginx配置文件地址]

切换日志文件:  

	kill -USR1 nginx pid

平滑升级可执行进程:  

    kill -USR2 nginx pid

从容关闭工作进程:  

	kill -WINCH nginx pid
	


