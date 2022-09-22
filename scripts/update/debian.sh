#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

if grep -Eq "Ubuntu" /etc/*-release; then
    sudo ln -sf /bin/bash /bin/sh
    #sudo dpkg-reconfigure dash
fi


cd /www/server/ng-panel/scripts && bash lib.sh
chmod 755 /www/server/ng-panel/data


if [ -f /etc/init.d/ng-panel ];then 
    sh /etc/init.d/ng-panel stop && rm -rf  /www/server/ng-panel/scripts/init.d/ng-panel && rm -rf  /etc/init.d/ng-panel
fi

echo -e "stop ng-panel"
isStart=`ps -ef|grep 'gunicorn -c setting.py app:app' |grep -v grep|awk '{print $2}'`

port=7200
if [ -f /www/server/ng-panel/data/port.pl ];then
    port=$(cat /www/server/ng-panel/data/port.pl)
fi

n=0
while [[ "$isStart" != "" ]];
do
    echo -e ".\c"
    sleep 0.5
    isStart=$(lsof -n -P -i:$port|grep LISTEN|grep -v grep|awk '{print $2}'|xargs)
    let n+=1
    if [ $n -gt 15 ];then
        break;
    fi
done


echo -e "start ng-panel"
cd /www/server/ng-panel && sh cli.sh start
isStart=`ps -ef|grep 'gunicorn -c setting.py app:app' |grep -v grep|awk '{print $2}'`
n=0
while [[ ! -f /etc/init.d/ng-panel ]];
do
    echo -e ".\c"
    sleep 0.5
    let n+=1
    if [ $n -gt 15 ];then
        break;
    fi
done
echo -e "start ng-panel success"

systemctl daemon-reload
/etc/init.d/ng-panel default


