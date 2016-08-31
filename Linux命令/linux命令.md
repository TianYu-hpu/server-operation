# Linux命令  
cat 命令用于查看文件内容  

tac 命令用于查看文件内容倒叙  
  
umask 显示或设置文件的缺省权限，在设置默认的缺省权限的时候采用掩码的形式来进行设置，比如说要设置文件的权限是754这样的权限，既rwxr-xr--这样的权限，使用777-754=023得到的023这个数字既掩码权限，通过 umask 023 来设置创建文件是的默认权限  

find 命令:  
使用: find [搜索范围] [匹配条件]  
例如: find /etc/ -name init 搜索 /etc 目录下文件名为 init 的文件，使用统配符进行搜索， *init* 搜索含有 init字符的所有文件，* 匹配多个字符， ? 匹配单个字符  

 locate updatedb  

  where, whereis  
  
  grep

  查看配置文件帮助信息  
   
  man services 这个services的名字应该在 /etc 目录下能够找到   
  man passwd 默认优先显示命令的帮助，使用whereis passwd 来查看会显示命令所在的位置及配置文件与帮助文档坐在的位置， /usr/share/man/man1/password.1.gz 是命令的帮助文件， /usr/share/man/man5/passwd.5.gz 是配置文件的帮助。 如何查看配置文件的帮助，在使用 man 命令的时候加上帮助文件级别就可以了，例如:
  man 5 passwd 

  使用 man 命令会打印出所有与该命令相关的信息，包括参数含义，如果想简化输出的话可以使用 whatis 来显示 man 命令中 name 显示的信息。  

  apropos 查看配置文件帮助信息  
  apropos services  
  命令 --help 会显示出该命令的参数信息，不会像 man 命令一样显示那么多的信息。

  who 查询登陆用户信息，第一列显示登陆的用户，第二列显示登陆用户所使用的终端，tty表示从本机登陆，pts 表示从远程登陆，第三列表示登陆时间，第四列表示登陆用户的ip地址  
  w 显示更为详细的用户登陆信息
  
  write 给用户发送信息，以 Ctrl + D 保存结束  

  wall: write all 给所有用户发送信息，发送广播  

  lastlog: 检查特定用户上次登陆的时间  

  setup:跳出文字图形界面的方式来设置网络相关信息 

## 软件包分类  
### 一、源码包  
安装较慢，能够查看源码，可定制较高
### 二进制包(RPM 包，系统默认包)  
#### RPM包命名规则:  
httpd-2.2.15-15.el6.centos.1.i686.rpm  
httpd				软件包名  
2.2.15				软件版本  
15					软件发布的次数  
el6.centos			适合的Linux平台  
i686				适合的硬件平台  
rpm					rpm包扩展名  

#### RPM包依赖性  
树形依赖: a -> b -> c  
安装的时候先安装 c 再安装 b 再安装 a,卸载的时候先卸载 a,再卸载 b, 再卸载 c
环形依赖: a -> b -> c -> a  
模块依赖: 模块依赖查询网站: www.rpmfind.net 

#### 包全名与包名：
什么时候使用包全名，什么时候使用包名  
包全名:操作的包是没有安装的软件包时，使用包全名。而且要注意路径。  
包名:操作已经安装的软件包时，使用包名。是搜索 /var/lib/rpm 中的数据库  
安装软件：

	rpm -ivh 包全名
    -i: install 安装
	-v: verbose 显示详细信息
	-h: hash 显示进度
	--nodeps: 不检测依赖性
升级软件：  
	
	rpm -Uvh 包全名
	-U: upgrade 升级

卸载软件:

	rpm -e 包名
	-e: erase 卸载
	--nodeps 不检查依赖性

查询是否安装:  

	rpm -q 包名
	-q: query  查询
	rpm -qa
	-a: all 所有
查询软件包详细信息  

	rpm -qi 包名
	-i: information 查询软件信息
	-p: package 查询未安装包信息  
查询包中文件安装位置:

	rpm -ql 包名
	-l: list 
	-p： package 查询未安装包信息
查询系统文件属于哪个rpm包

	rpm -qf 系统文件名
	-f: file 查询系统文件属于哪个软件包
查询软件包的依赖性

	rpm -qR 包名
	-R: requires 查询软件包的依赖性
	-p: package 查询未安装包信息
rpm包校验

	rpm -V 已安装的包名
	-V: verify 校验指定rpm包中的文件
验证内容中的8个信息的具体内容如下:  
S：文件大小是否改变  
M:文件的类型或文件的权限(rwx)是否发生改变  
5:文件的MD5校验和是否改变  
D:设备中从代码是否改变  
L:文件路径是否改变  
U:文件的所有者是否改变  
G:文件的所属组是否改变  
T:文件的修改时间是否改变  

文件类型:  
c： 配置文件(config file)  
d：普通文档(documentation)  
g:鬼文件(ghost file),很少见，就是该文件不应该被这个RPM包所包含  
l:授权文件(license file)  
r：描述文件(read me)  

rpm包中文件提取  
rpm2cpio 包全名 | cpio -idv .文件绝对路径