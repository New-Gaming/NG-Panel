#!/bin/bash
# chkconfig: 2345 55 25
# description: NG-Panel Cloud Service

### BEGIN INIT INFO
# Provides:          NG-Panel
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts NG-Panel
# Description:       starts the NG-Panel
### END INIT INFO


PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LC_ALL="en_US.UTF-8"

ng_path={$SERVER_PATH}
PATH=$PATH:$ng_path/bin


if [ -f $ng_path/bin/activate ];then
    source $ng_path/bin/activate
else 
    echo ""
fi

ng_start_panel()
{
    isStart=`ps -ef|grep 'gunicorn -c setting.py app:app' |grep -v grep|awk '{print $2}'`
    if [ "$isStart" == '' ];then
        echo -e "Starting ng-panel... \c"
        cd $ng_path &&  gunicorn -c setting.py app:app
        port=$(cat ${ng_path}/data/port.pl)
        isStart=""
        while [[ "$isStart" == "" ]];
        do
            echo -e ".\c"
            sleep 0.5
            isStart=$(lsof -n -P -i:$port|grep LISTEN|grep -v grep|awk '{print $2}'|xargs)
            let n+=1
            if [ $n -gt 15 ];then
                break;
            fi
        done
        if [ "$isStart" == '' ];then
                echo -e "\033[31mfailed\033[0m"
                echo '------------------------------------------------------'
                tail -n 20 ${ng_path}/logs/error.log
                echo '------------------------------------------------------'
                echo -e "\033[31mError: ng-panel service startup failed.\033[0m"
                return;
        fi
        echo -e "\033[32mdone\033[0m"
    else
        echo "Starting ng-panel... (pid $(echo $isStart)) already running"
    fi
}


ng_start_task()
{
    isStart=$(ps aux |grep 'task.py'|grep -v grep|awk '{print $2}')
    if [ "$isStart" == '' ];then
        echo -e "Starting ng-tasks... \c"
        cd $ng_path && python3 task.py >> ${ng_path}/logs/task.log 2>&1 &
        sleep 0.3
        isStart=$(ps aux |grep 'task.py'|grep -v grep|awk '{print $2}')
        if [ "$isStart" == '' ];then
                echo -e "\033[31mfailed\033[0m"
                echo '------------------------------------------------------'
                tail -n 20 $ng_path/logs/task.log
                echo '------------------------------------------------------'
                echo -e "\033[31mError: ng-tasks service startup failed.\033[0m"
                return;
        fi
        echo -e "\033[32mdone\033[0m"
    else
        echo "Starting ng-tasks... ng-tasks (pid $(echo $isStart)) already running"
    fi
}

ng_start()
{
    ng_start_task
	ng_start_panel
}


ng_stop_task()
{
    if [ -f $ng_path/tmp/panelTask.pl ];then
        echo -e "\033[32mThe task is running and cannot be stopped\033[0m"
        exit 0
    fi

    echo -e "Stopping ng-tasks... \c";
    pids=$(ps aux | grep 'task.py'|grep -v grep|awk '{print $2}')
    arr=($pids)
    for p in ${arr[@]}
    do
            kill -9 $p
    done
    echo -e "\033[32mdone\033[0m"
}

ng_stop_panel()
{
    echo -e "Stopping ng-panel... \c";
    arr=`ps aux|grep 'gunicorn -c setting.py app:app'|grep -v grep|awk '{print $2}'`
    for p in ${arr[@]}
    do
            kill -9 $p &>/dev/null
    done
    
    if [ -f $pidfile ];then
        rm -f $pidfile
    fi
    echo -e "\033[32mdone\033[0m"
}

ng_stop()
{
    ng_stop_task
    ng_stop_panel
}

ng_status()
{
        isStart=$(ps aux|grep 'gunicorn -c setting.py app:app'|grep -v grep|awk '{print $2}')
        if [ "$isStart" != '' ];then
                echo -e "\033[32mng-panel (pid $(echo $isStart)) already running\033[0m"
        else
                echo -e "\033[31mng-panel not running\033[0m"
        fi
        
        isStart=$(ps aux |grep 'task.py'|grep -v grep|awk '{print $2}')
        if [ "$isStart" != '' ];then
                echo -e "\033[32mng-task (pid $isStart) already running\033[0m"
        else
                echo -e "\033[31mng-task not running\033[0m"
        fi
}


ng_reload()
{
	isStart=$(ps aux|grep 'gunicorn -c setting.py app:app'|grep -v grep|awk '{print $2}')
    
    if [ "$isStart" != '' ];then
    	echo -e "Reload ng-panel... \c";
	    arr=`ps aux|grep 'gunicorn -c setting.py app:app'|grep -v grep|awk '{print $2}'`
		for p in ${arr[@]}
        do
                kill -9 $p
        done
        cd $ng_path && gunicorn -c setting.py app:app
        isStart=`ps aux|grep 'gunicorn -c setting.py app:app'|grep -v grep|awk '{print $2}'`
        if [ "$isStart" == '' ];then
                echo -e "\033[31mfailed\033[0m"
                echo '------------------------------------------------------'
                tail -n 20 $ng_path/logs/error.log
                echo '------------------------------------------------------'
                echo -e "\033[31mError: ng-panel service startup failed.\033[0m"
                return;
        fi
        echo -e "\033[32mdone\033[0m"
    else
        echo -e "\033[31mng-panel not running\033[0m"
        ng_start
    fi
}


error_logs()
{
	tail -n 100 $ng_path/logs/error.log
}

case "$1" in
    'start') ng_start;;
    'stop') ng_stop;;
    'reload') ng_reload;;
    'restart') 
        ng_stop
        ng_start;;
    'restart_panel')
        ng_stop_panel
        ng_start_panel;;
    'restart_task')
        ng_stop_task
        ng_start_task;;
    'status') ng_status;;
    'logs') error_logs;;
    'default')
        cd $ng_path
        port=7200
        
        if [ -f $ng_path/data/port.pl ];then
            port=$(cat $ng_path/data/port.pl)
        fi

        if [ ! -f $ng_path/data/default.pl ];then
            echo -e "\033[33mInstall Failed\033[0m"
            exit 1
        fi

        password=$(cat $ng_path/data/default.pl)
        if [ -f $ng_path/data/domain.conf ];then
            address=$(cat $ng_path/data/domain.conf)
        fi
        if [ -f $ng_path/data/admin_path.pl ];then
            auth_path=$(cat $ng_path/data/admin_path.pl)
        fi
	    
        if [ "$address" = "" ];then
            v4=$(python3 $ng_path/tools.py getServerIp 4)
            v6=$(python3 $ng_path/tools.py getServerIp 6)

            if [ "$v4" != "" ] && [ "$v6" != "" ]; then
                address="NG-Panel-Url-Ipv4: http://$v4:$port$auth_path \nNG-Panel-Url-Ipv6: http://[$v6]:$port$auth_path"
            elif [ "$v4" != "" ]; then
                address="NG-Panel-Url: http://$v4:$port$auth_path"
            elif [ "$v6" != "" ]; then
                echo 'True' > $ng_path/data/ipv6.pl
                address="NG-Panel-Url: http://[$v6]:$port$auth_path"
            else
                address="No v4 or v6 available"
            fi
        else
            address="NG-Panel-Url: http://$address:$port$auth_path"
        fi

        echo -e "=================================================================="
        echo -e "\033[32mNG-Panel default info!\033[0m"
        echo -e "=================================================================="
        echo -e "$address"
        echo -e `python3 $ng_path/tools.py username`
        echo -e "password: $password"
        echo -e "\033[33mWarning:\033[0m"
        echo -e "\033[33mIf you cannot access the panel, \033[0m"
        echo -e "\033[33mrelease the following port (7200|888|80|443|22) in the security group\033[0m"
        echo -e "=================================================================="
        ;;
esac
