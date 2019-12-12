FROM php:7.4.0-fpm-alpine
MAINTAINER ymc-github <yemiancheng@gmail.com>
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories   && docker-php-source extract   && docker-php-ext-install mysqli pdo pdo_mysql   && docker-php-source delete
CMD ["php-fpm","-R"]
