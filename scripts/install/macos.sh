#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

USER=$(who | sed -n "2,1p" |awk '{print $1}')
DEV="/Users/${USER}/Desktop/mwdev"


mkdir -p $DEV
mkdir -p $DEV/wwwroot
mkdir -p $DEV/server
mkdir -p $DEV/wwwlogs
mkdir -p $DEV/backup/database
mkdir -p $DEV/backup/site

# install brew
if [ ! -f /usr/local/bin/brew ];then
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew install python@2
	brew install mysql
fi

brew install libzip bzip2 gcc openssl re2c cmake


cd /www/server/ng-panel/scripts && bash lib.sh
chmod 755 /www/server/ng-panel/data


cd /www/server/ng-panel && ./cli.sh start
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


cd /www/server/ng-panel && /etc/init.d/ng-panel stop
cd /www/server/ng-panel && /etc/init.d/ng-panel start
cd /www/server/ng-panel && /etc/init.d/ng-panel default