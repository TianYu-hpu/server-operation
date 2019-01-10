#!/usr/bin/bash
# comment: install software
# date； 2016-12-04
# author： TianYu
# email: TianYu.hpu@gmail.com

echo "yum makecache"
yum makecache

echo "install vim git mlocate python-settools net-tools"
yum install -y vim git net-tools mlocate python-setuptools

echo "install compile tools"
yum install -y make automake gcc gcc-c perl-devel perl-ExtUtils-Embed

echo "install java openjdk 1.7.0"
yum install -y java-1.7.0-openjdk.x86_64

echo "install pcre"
yum install -y pcre-devel.x86_64 pcre-static.x86_64 pcre-tools.x86_64  pcre.x86_64

echo "install mysql yum repository & instlal webmin"
yum localinstall -y /home/TianYu/download/*.rpm

echo "install telnet tool"
yum install -y telnet

echo "yum install flex byacc  libpcap ncurses ncurses-devel libpcap-devel"
yum install -y  flex byacc  libpcap ncurses ncurses-devel

echo "install wget"
yum install -y wget
echo "install done"



