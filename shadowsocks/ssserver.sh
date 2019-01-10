#!/bin/bash
#name: ssserver.sh
# author: TianYu
# date: 2016-09-04
# desc: start shadowsocks server on boot
 
RUN_AS_USER=root
/usr/bin/ssserver -p 8080 -k ShadowSocks -m aes-256-cfb --user nobody --workers 2 -d start
