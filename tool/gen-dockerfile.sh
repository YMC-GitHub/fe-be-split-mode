#!/bin/sh

THIS_FILE_PATH=$(
  cd $(dirname $0)
  pwd
)
source $THIS_FILE_PATH/function-list.sh
source $THIS_FILE_PATH/config.sh
THIS_PROJECT_PATH=$(path_resolve "$THIS_FILE_PATH" "../")
RUN_SCRIPT_PATH=$(pwd)

function add_mysql() {
  local author=
  local email=
  local TXT=
  author=ymc-github
  email=yemiancheng@gmail.com
  local TXT=
  TXT=$(
    cat <<EOF
######
# See: https://github.com/YMC-GitHub/mirror-mysql
######

# data serve with mysql
#FROM registry.cn-hangzhou.aliyuncs.com/yemiancheng/mysql:alpine-3.10.3
#FROM mariadb:10.1.13
#FROM mariadb:10.2.30
FROM mariadb:$MYSQL_VERSION
#FROM mariadb:10.3.21
#FROM mariadb:10.4.11
LABEL MAINTAINER ymc-github <yemiancheng@gmail.com>
#EXPOSE 3306
#set timezone
#uses local pm time with -v /etc/localtime:/etc/localtime in compose file
#RUN apk add -U tzdata &&  cp "/usr/share/zoneinfo/Asia/Shanghai" "/etc/localtime" && apk del tzdata
#COPY \$(pwd)/mysql/conf/my.cnf /etc/mysql/my.cnf
#https://mariadb.com/kb/en/library/system-variable-differences-between-mariadb-and-mysql/
#https://hub.docker.com/_/mariadb
#https://blog.csdn.net/dongdong9223/article/details/86645690
# get the relation with mysql and mariadb
# mysql -V
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function add_tomcat() {
  local author=
  local email=
  local TXT=
  author=ymc-github
  email=yemiancheng@gmail.com
  local TXT=
  TXT=$(
    cat <<EOF
######
# See: https://hub.docker.com/_/tomcat
######
# web serve with tomcat
#FROM tomcat:8.5.41-jre8-alpine
FROM tomcat:${TOMCAT_VERSION}-alpine
LABEL MAINTAINER $author <$email>
#https://hub.docker.com/_/tomcat?tab=tags&page=1&name=alpine
#https://hub.docker.com/_/openjdk?tab=tags&page=1&name=8-jdk-alpine
#https://hub.docker.com/_/openjdk?tab=tags&page=1&name=8-jre-alpine
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function add_redis() {
  local author=
  local email=
  local TXT=
  author=ymc-github
  email=yemiancheng@gmail.com
  local TXT=
  TXT=$(
    cat <<EOF
######
# See: https://hub.docker.com/_/redis
######
# data serve with redis
#https://hub.docker.com/_/redis?tab=tags&page=1&name=alpine
FROM redis:${REDIS_VERSION}-alpine3.10
LABEL MAINTAINER $author <$email>
#COPY redis-master/conf/redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}
function add_activemq() {
  local author=
  local email=
  local TXT=
  author=ymc-github
  email=yemiancheng@gmail.com
  local TXT=
  TXT=$(
    cat <<EOF
######
# See: https://hub.docker.com/r/rmohr/activemq
######
# https://hub.docker.com/r/rmohr/activemq
FROM rmohr/activemq:${ACTIVEMQ_VERSION}-alpine
LABEL MAINTAINER $author <$email>
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function add_nodejs() {
  local author=
  local email=
  local TXT=
  author=ymc-github
  email=yemiancheng@gmail.com
  local TXT=
  TXT=$(
    cat <<EOF
######
# See: https://hub.docker.com/_/nodejs
######
FROM node:${NODEJS_VERSION}-alpine3.10
LABEL MAINTAINER $author <$email>
EXPOSE 3000
ENV PROJECT_DIR=/usr/share/nginx/html
WORKDIR \$PROJECT_DIR
CMD ["node", "./fe/index.js"]

EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function add_nginx() {
  local author=
  local email=
  local TXT=
  author=ymc-github
  email=yemiancheng@gmail.com
  local TXT=
  TXT=$(
    cat <<EOF
######
# See: https://hub.docker.com/_/nginx
######
FROM nginx:${NGINX_VERSION}-alpine
LABEL MAINTAINER $author <$email>

EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function main_fun() {
  local path=
  local TXT=
  local list=
  local arr=
  local key=
  local val=
  local str=

  list=$(
    cat <<EOF
mysql=mysql
#mongo=mongo
#redis=redis
tomcat=tomcat
maven=maven
#activemq=activemq
nodejs=nodejs
nginx=nginx
EOF
  )

  list=$(echo "$list" | sed "s/^ *#.*//g" | sed "/^$/d")
  list=$(echo "$list" | sed "s/.*maven.*//g" | sed "/^$/d")
  arr=(${list//,/ })
  for i in "${arr[@]}"; do
    # 获取键名
    key=$(echo $i | awk -F'=' '{print $1}')
    # 获取键值
    val=$(echo $i | awk -F'=' '{print $2}')

    path="$THIS_PROJECT_PATH/$val/Dockerfile"
    echo "gen Dockerfile :$path"
    TXT=$(add_$val)
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT" >"$path"
  done
}
main_fun "$PROJECT_DIR_CONSTRUTOR"

#### usage
#./tool/gen-dockerfile.sh
