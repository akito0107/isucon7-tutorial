#!/bin/bash -eu

GO_WEBAPP_ROOT=$HOME/isubata/webapp/go
GO_WEBAPP_BACKUP=$HOME/go_backup
echo "WEBAPP ROOT"${GO_WEBAPP_ROOT}

echo 'git pull'
git pull origin master

golang_deploy() {
	if test -e ${GO_WEBAPP_BACKUP}; then
		echo "rm -rf ${GO_WEBAPP_BACKUP}"
		rm -rf ${GO_WEBAPP_BACKUP}
	fi
	
	echo "mv ${GO_WEBAPP_ROOT} ${GO_WEBAPP_BACKUP}"
	mv ${GO_WEBAPP_ROOT} ${GO_WEBAPP_BACKUP}
	
	echo "cp -r ./go ${GO_WEBAPP_ROOT}"
	cp -r ./go ${GO_WEBAPP_ROOT}
	
	echo "cd ${GO_WEBAPP_ROOT}"
	cd ${GO_WEBAPP_ROOT}
	
	make
	
	echo "sudo systemctl restart isubata.golang.service"
	sudo systemctl restart isubata.golang.service
	
	echo "golang deploy done"
}

nginx_deploy() {
	if test -e /etc/nginx/nginx.conf.bak; then
		echo "rm /etc/nginx/nginx.conf/bak"
		sudo rm /etc/nginx/nginx.conf.bak
	fi

	sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

	sudo cp sites-available/* /etc/nginx/sites-available/
	
	echo "cp nginx.conf /etc/nginx.conf"
	sudo cp nginx.conf /etc/nginx/nginx.conf

	echo "sudo systemctl restart nginx.service"
	sudo systemctl restart nginx.service

	echo "nginx deploy done"
}

mysql_deploy() {
	if test -e /etc/mysql/conf.d/mysql.cnf.bak; then
		echo "rm /etc/mysql/conf.d/mysql.cnf.bak"
		sudo rm /etc/mysql/conf.d/mysql.cnf.bak
	fi

	sudo cp /etc/mysql/conf.d/mysql.cnf /etc/mysql/conf.d/mysql.cnf.bak

	echo "cp mysql.cnf /etc/mysql/conf.d/mysql.cnf"
	sudo cp mysql.cnf /etc/mysql/conf.d/mysql.cnf

	if test -e /etc/mysql/mysql.conf.d/mysqld.cnf.bak; then
		echo "rm /etc/mysql/mysql.conf.d/mysqld.cnf.bak"
		sudo rm /etc/mysql/mysql.conf.d/mysqld.cnf.bak
	fi

	sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
	
	echo "cp mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf"
	sudo cp mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
	
	echo "sudo systemctl restart mysql.service"
	sudo sudo systemctl restart mysql.service

	echo "mysql deploy done"
}

case $1 in 
	"nginx" )  nginx_deploy;;
	"mysql" ) mysql_deploy;;
	"golang" ) golang_deploy;;
	"all") 
		mysql_deploy;
		golang_deploy;
		nginx_deploy;;
esac

