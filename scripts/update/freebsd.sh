#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8


cd /www/server/ng-panel/scripts && bash lib.sh
chmod 755 /www/server/ng-panel/data

if [ -f /etc/init.d/ng-panel ];then
    sh /etc/init.d/ng-panel stop && rm -rf  /www/server/ng-panel/scripts/init.d/ng-panel && rm -rf  /etc/init.d/ng-panel
fi


cd /www/server/ng-panel && bash cli.sh start
isStart=`ps -ef|grep 'gunicorn -c setting.py app:app' |grep -v grep|awk '{print $2}'`
n=0
while [[ ! -f /etc/init.d/ng-panel ]];
do
    echo -e ".\c"
    sleep 1
    let n+=1
    if [ $n -gt 20 ];then
    	echo -e "start ng-panel fail"
        exit 1
    fi
done

cd /www/server/ng-panel && bash /etc/init.d/ng-panel stop
cd /www/server/ng-panel && bash /etc/init.d/ng-panel start
cd /www/server/ng-panel && bash /etc/init.d/ng-panel default

