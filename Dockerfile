FROM hub.c.163.com/library/php:7.1.6-apache

MAINTAINER xiaobe <wyy.xb@qq.com>

RUN apt-get update \
    && apt-get install -y vim libpng-dev git memcached


    # 官方 PHP 镜像内置命令，安装 PHP 依赖
RUN docker-php-ext-install mysqli pdo_mysql gd \
    && pecl install swoole \
    && docker-php-ext-enable swoole \

    # 安装memcache扩展
    && git clone https://github.com/websupport-sk/pecl-memcache /usr/src/php/ext/memcache \
    && cd /usr/src/php/ext/memcache \
    && phpize \
    && ./configure \
    && make all \
    && docker-php-ext-install memcache \
    && docker-php-ext-enable memcache \

    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN usermod -u 1000 www-data \
    && usermod -g root www-data \
    && echo Listen\ 5050>>/etc/apache2/ports.conf

ADD ./display.ini /usr/local/etc/php/conf.d 
ADD ./000-default.conf /etc/apache2/sites-available/000-default.conf 

# COPY code /var/www/html
# RUN chmod 777 -R /var/www/html


EXPOSE 8866 80 5050 

CMD /usr/bin/memcached -d -m 50 -p 11211 -u root -v && apache2-foreground
