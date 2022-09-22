#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

curPath=`pwd`

rootPath=$(dirname "$curPath")
rootPath=$(dirname "$rootPath")
rootPath=$(dirname "$rootPath")
rootPath=$(dirname "$rootPath")
serverPath=$(dirname "$rootPath")
sourcePath=${serverPath}/source/php

actionType=$1
version=$2

LIBNAME=gd
LIBV=0


# if [ "$version" -lt "74" ];then
# 	echo "not need!"
# 	exit 1
# fi


LIB_PATH_NAME=lib/php
if [ -d $serverPath/php/${version}/lib64 ];then
	LIB_PATH_NAME=lib64
fi

NON_ZTS_FILENAME=`ls $serverPath/php/${version}/${LIB_PATH_NAME}/extensions | grep no-debug-non-zts`
extFile=$serverPath/php/${version}/${LIB_PATH_NAME}/extensions/${NON_ZTS_FILENAME}/${LIBNAME}.so

sysName=`uname`
if [ "$sysName" == "Darwin" ];then
	BAK='_bak'
else
	BAK=''
fi


# cd $serverPath/ng-panel/plugins/php/lib && /bin/bash freetype_old.sh
# OPTIONS="${OPTIONS} --with-freetype-dir=${serverPath}/lib/freetype_old"
# OPTIONS="${OPTIONS} --with-gd --enable-gd-native-ttf"
# OPTIONS="${OPTIONS} --with-jpeg --with-jpeg-dir=/usr/lib"


Install_lib()
{

	isInstall=`cat $serverPath/php/$version/etc/php.ini|grep "${LIBNAME}.so"`
	if [ "${isInstall}" != "" ];then
		echo "php-$version 已安装${LIBNAME},请选择其它版本!"
		return
	fi

	cd $serverPath/ng-panel/plugins/php/lib && /bin/bash freetype_old.sh
	
	if [ ! -f "$extFile" ];then

		if [ ! -d $sourcePath/php${version}/ext ];then
			cd $serverPath/ng-panel/plugins/php && /bin/bash install.sh install ${version}
		fi
		
		cd $sourcePath/php${version}/ext/${LIBNAME}
		
		$serverPath/php/$version/bin/phpize

		#--with-xpm
		# =${serverPath}/lib/freetype_old
		# =/usr/lib
		./configure --with-php-config=$serverPath/php/$version/bin/php-config \
		--with-gd \
		--with-jpeg-dir \
		--with-freetype-dir=${serverPath}/lib/freetype_old \
		--enable-gd-jis-conv \
		--enable-gd-native-ttf
		make clean && make && make install && make clean
		
	fi

	if [ ! -f "$extFile" ];then
		echo "ERROR!"
		return
	fi

    echo "" >> $serverPath/php/$version/etc/php.ini
	echo "[${LIBNAME}]" >> $serverPath/php/$version/etc/php.ini
	echo "extension=${LIBNAME}.so" >> $serverPath/php/$version/etc/php.ini
	
	bash ${rootPath}/plugins/php/versions/lib.sh $version restart
	echo '==========================================================='
	echo 'successful!'
}


Uninstall_lib()
{
	if [ ! -f "$serverPath/php/$version/bin/php-config" ];then
		echo "php-$version 未安装,请选择其它版本!"
		return
	fi
	
	if [ ! -f "$extFile" ];then
		echo "php-$version 未安装${LIBNAME},请选择其它版本!"
		return
	fi
	
	echo $serverPath/php/$version/etc/php.ini
	sed -i $BAK "/${LIBNAME}.so/d" $serverPath/php/$version/etc/php.ini
	sed -i $BAK "/${LIBNAME}/d" $serverPath/php/$version/etc/php.ini
		
	rm -f $extFile
	bash ${rootPath}/plugins/php/versions/lib.sh $version restart
	echo '==============================================='
	echo 'successful!'
}



if [ "$actionType" == 'install' ];then
	Install_lib
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_lib
fi