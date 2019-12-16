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
  local TXT=
  TXT=$(
    cat <<EOF
# data serve with mysql
  mysql:
    hostname: mysql
    #container_name: mysql-$MYSQL_VERSION
    container_name: ${CM_MYSQL_NAME}
    build: ./mysql
    ports:
      - 3308:3306
    networks:
      staticnymc:
        ipv4_address: 172.20.1.3
    environment:
      MYSQL_ROOT_PASSWORD: yourpassword
      #      MYSQL_DATABASE: xxx
      #      MYSQL_USER: xxx
      #      MYSQL_PASSWORD: xxx123456
      TZ: Asia/Shanghai
      LANG: en_US.UTF-8
    volumes:
      # conf
      - ./mysql/my.cnf:/etc/mysql/my.cnf
      # data
      - ./mysql/data:/app/mysql
      # backup
      - ./mysql/backup:/backup
      # date and time
      - /etc/localtime:/etc/localtime
    restart: always
  #    restart: unless-stopped
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function add_tomcat() {
  local TXT=
  TXT=$(
    cat <<EOF
  tomcat:
    # set his host name
    hostname: tomcat
    # only [a-zA-Z0-9][a-zA-Z0-9_.-] are allowed
    #container_name: $CM_TOMCAT_NAME
    container_name: ${CM_TOMCAT_NAME}
    # set the cm  it depends on
    depends_on:
      - mysql
    #  - redis_master
    #  - redis_slave
    #  - activemq
    build: ./tomcat
    # must to be the same with ./tomcat/conf/server.xml
    ports:
      - 8080:8080
    # define your owen network
    networks:
      staticnymc:
        ipv4_address: 172.20.1.2
    #    - 80:80
    #    - 443:443
    # set pm/vm dir path map to cm dir path
    volumes:
      - ./tomcat/conf:/usr/local/tomcat/conf
      - ./tomcat/logs:/usr/local/tomcat/logs
      - /etc/localtime:/etc/localtime
      #- ./tomcat/webapps:/usr/local/tomcat/webapps
      - ./app/be/webapps:/usr/local/tomcat/webapps
    # set some env var for cm
    environment:
      JAVA_OPTS: -Dfile.encoding=UTF-8
      TZ: Asia/Shanghai
      LANG: en_US.UTF-8
    # set the start mode of cm for pro
    restart: always
  #    restart: unless-stopped
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function add_network() {
  local TXT=
  TXT=$(
    cat <<EOF
networks:
  staticnymc:
    ipam:
      config:
        - subnet: 172.20.1.0/24
          gateway: 172.20.1.1
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}
function add_redis() {
  local TXT=
  local node=
  local SERVE_SUFFIX=
  if [ -n "${1}" ]; then
    node="-${1}"
    SERVE_SUFFIX="_${1}"
  fi

  TXT=$(
    cat <<EOF
  redis${SERVE_SUFFIX}:
    hostname: redis${node}
    container_name: ${CM_REDIS_NAME}${node}
    build: ./redis${node}
    ports:
      - 6379:6379
    networks:
      staticnymc:
        ipv4_address: 172.20.1.4
    volumes:
      - ./redis${node}/data:/data
      - /etc/localtime:/etc/localtime
      - ./redis${node}/conf/redis.conf:/usr/local/etc/redis/redis.conf
    #command: redis-server /usr/local/etc/redis/redis.conf
    environment:
      TZ: Asia/Shanghai
      LANG: en_US.UTF-8
    restart: always
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function add_activemq() {
  local TXT=
  TXT=$(
    cat <<EOF
  activemq:
    hostname: activemq
    container_name: ${CM_ACTIVEMQ_NAME}
    build: ./activemq
    ports:
      - 8161:8161
      - 61616:61616
    networks:
      staticnymc:
        ipv4_address: 172.20.1.6
    volumes:
      - ./activemq/data:/data/activemq
      - ./activemq/logs:/var/log/activemq
      - /etc/localtime:/etc/localtime
    environment:
      ACTIVEMQ_ADMIN_LOGIN: admin
      ACTIVEMQ_ADMIN_PASSWORD: admin
      ACTIVEMQ_CONFIG_MINMEMORY: 512
      ACTIVEMQ_CONFIG_MAXMEMORY: 2048
      TZ: Asia/Shanghai
      LANG: en_US.UTF-8
    restart: always
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}
function add_nodejs() {
  local TXT=
  TXT=$(
    cat <<EOF
  nodejs:
    hostname: nodejs
    container_name: ${CM_NODEJS_NAME}
    build: ./nodejs
    ports:
      - 3000:3000
    networks:
      staticnymc:
        ipv4_address: 172.20.1.7
    volumes:
      - ./app:/usr/share/nginx/html
      - /etc/localtime:/etc/localtime
    restart: always
    links:
      - mysql:mysql
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}
function add_nginx() {
  local TXT=
  TXT=$(
    cat <<EOF
  nginx:
    hostname: nginx
    container_name: ${CM_NGINX_NAME}
    build: ./nginx
    ports:
      - 80:80
      - 443:443
      - 8081:80
    networks:
      staticnymc:
        ipv4_address: 172.20.1.8
    volumes:
      - ./app:/usr/share/nginx/html
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d/:/etc/nginx/conf.d/:ro
      - ./nginx/ca/server.crt/:/etc/nginx/server.crt:ro
      - ./nginx/ca/server.key/:/etc/nginx/server.key:ro
      - /etc/localtime:/etc/localtime
    restart: always
    links:
    - tomcat:__DOCKER_TOMCAT__
    - nodejs:__DOCKER_FE_NODEJS__
EOF
  )
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT"
}

function main_fun() {
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

  TXT=$(
    cat <<EOF
version: '2'
services:
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
    str=$(add_$val)
    TXT=$(
      cat <<EOF
$TXT
$str
EOF
    )
  done
  str=$(add_network)
  TXT=$(
    cat <<EOF
$TXT
$str
EOF
  )

  echo "gen docker-compose.yml :$THIS_PROJECT_PATH/docker-compose.yml"
  TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
  echo "$TXT" >"$THIS_PROJECT_PATH/docker-compose.yml"
}

main_fun "$PROJECT_DIR_CONSTRUTOR"
#### usage
#./tool/gen-docker-compose.sh
