# Linux命令  
cat 命令用于查看文件内容  

tac 命令用于查看文件内容倒叙  
  
umask 显示或设置文件的缺省权限，在设置默认的缺省权限的时候采用掩码的形式来进行设置，比如说要设置文件的权限是754这样的权限，既rwxr-xr--这样的权限，使用777-754=023得到的023这个数字既掩码权限，通过 umask 023 来设置创建文件是的默认权限  
## 查找命令  
### find 命令:  
使用: find [搜索范围] [匹配条件]  
例如: find /etc/ -name init 搜索 /etc 目录下文件名为 init 的文件，使用统配符进行搜索， *init* 搜索含有 init字符的所有文件，* 匹配多个字符， ? 匹配单个字符  

### locate updatedb  

### where, whereis  
  
### grep

## 查看配置文件帮助信息  
   
  man services 这个services的名字应该在 /etc 目录下能够找到   
  man passwd 默认优先显示命令的帮助，使用whereis passwd 来查看会显示命令所在的位置及配置文件与帮助文档坐在的位置， /usr/share/man/man1/password.1.gz 是命令的帮助文件， /usr/share/man/man5/passwd.5.gz 是配置文件的帮助。 如何查看配置文件的帮助，在使用 man 命令的时候加上帮助文件级别就可以了，例如:
  man 5 passwd 

  使用 man 命令会打印出所有与该命令相关的信息，包括参数含义，如果想简化输出的话可以使用 whatis 来显示 man 命令中 name 显示的信息。  

## apropos 查看配置文件帮助信息  
  apropos services  
  命令 --help 会显示出该命令的参数信息，不会像 man 命令一样显示那么多的信息。

  who 查询登陆用户信息，第一列显示登陆的用户，第二列显示登陆用户所使用的终端，tty表示从本机登陆，pts 表示从远程登陆，第三列表示登陆时间，第四列表示登陆用户的ip地址  
  w 显示更为详细的用户登陆信息
  
  write 给用户发送信息，以 Ctrl + D 保存结束  

  wall: write all 给所有用户发送信息，发送广播  

  lastlog: 检查特定用户上次登陆的时间  

  setup:跳出文字图形界面的方式来设置网络相关信息 

