#!/bin/bash

case $1 in
	deploy)
		if docker network ls --format "{{.Name}}" | grep  MyNetwork>/dev/null; then
			echo Network already exists
		else
			docker network create MyNetwork
		fi
		if docker ps -a | grep wordpress>/dev/null && docker ps -a | grep mysql>/dev/null; then
			echo Containers already exists
		else
			docker run -dp80:80 \
				--mount type=volume,source=wordpress_wordpress,target=/var/www/html \
				--network=MyNetwork \
				--name=wordpress \
				-e WORDPRESS_DB_HOST=mysql \
				-e WORDPRESS_DB_USER=admin \
				-e WORDPRESS_DB_PASSWORD=secret \
				-e WORDPRESS_DB_NAME=wordpressdb \
				wordpress
			
			docker run \
				-d \
				--mount type=volume,source=wordpress_db,target=/var/lib/mysql \
				--network=MyNetwork \
				--name=mysql \
				-e MYSQL_DATABASE=wordpressdb \
				-e MYSQL_USER=admin \
				-e MYSQL_PASSWORD=secret \
				-e MYSQL_ROOT_PASSWORD=my-secret-pw \
				mysql
		fi
		;;
	remove)
		if docker ps -a | grep mysql>/dev/null; then
			matchmysql=$(docker ps | grep mysql | cut -d " " -f1)
			docker stop $matchmysql && docker rm $matchmysql>/dev/null
		fi
		if docker ps -a | grep wordpress>/dev/null; then
			matchwp=$(docker ps | grep wordpress | cut -d " " -f1)
			docker stop $matchwp && docker rm $matchwp>/dev/null
		fi
		if docker network ls | grep MyNetwork>/dev/null; then
			docker network remove MyNetwork
		fi
		
	;;
	*)
		echo unknown
	;;

esac
