FROM alpine:3.7 
MAINTAINER corealugly 

ARG DOKUWIKI_VERSION=2017-02-19e
ARG DOKUWIKI_MD5_CHECKSUM=09bf175f28d6e7ff2c2e3be60be8c65f

RUN apk --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ add \ 
    php7 php7-fpm php7-gd php7-session php7-xml nginx supervisor curl tar

RUN mkdir -p /run/nginx /var/www /var/dokuwiki-storage/data 
RUN wget -q -O /dokuwiki.tgz "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz"
RUN echo $(md5sum /dokuwiki.tgz)
RUN if [ "$DOKUWIKI_MD5_CHECKSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi
RUN mkdir /var/www/dokuwiki && \
    tar -zxf dokuwiki.tgz -C /var/www/dokuwiki --strip-components 1 && \
    rm dokuwiki.tgz

RUN mv /var/www/dokuwiki/data/pages /var/dokuwiki-storage/data/pages && \ 
    ln -s /var/dokuwiki-storage/data/pages /var/www/dokuwiki/data/pages && \ 
    mv /var/www/dokuwiki/data/meta /var/dokuwiki-storage/data/meta && \ 
    ln -s /var/dokuwiki-storage/data/meta /var/www/dokuwiki/data/meta && \ 
    mv /var/www/dokuwiki/data/media /var/dokuwiki-storage/data/media && \ 
    ln -s /var/dokuwiki-storage/data/media /var/www/dokuwiki/data/media && \ 
    mv /var/www/dokuwiki/data/media_attic /var/dokuwiki-storage/data/media_attic && \ 
    ln -s /var/dokuwiki-storage/data/media_attic /var/www/dokuwiki/data/media_attic && \ 
    mv /var/www/dokuwiki/data/media_meta /var/dokuwiki-storage/data/media_meta && \ 
    ln -s /var/dokuwiki-storage/data/media_meta /var/www/dokuwiki/data/media_meta && \ 
    mv /var/www/dokuwiki/data/attic /var/dokuwiki-storage/data/attic && \ 
    ln -s /var/dokuwiki-storage/data/attic /var/www/dokuwiki/data/attic && \ 
    mv /var/www/dokuwiki/conf /var/dokuwiki-storage/conf && \ 
    ln -s /var/dokuwiki-storage/conf /var/www/dokuwiki/conf

RUN rm -v /etc/nginx/conf.d/default.conf
ADD files/dokuwiki.conf /etc/nginx/conf.d/dokuwiki.conf 
ADD files/supervisord.conf /etc/supervisord.conf 
ADD files/start.sh /start.sh
RUN chmod +x /start.sh 

RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php7/php-fpm.ini && \ 
    sed -e "s|;daemonize\s*=\s*yes|daemonize = no|g" -i /etc/php7/php-fpm.conf && \ 
    sed -e "s|listen\s*=\s*127\.0\.0\.1:9000|listen = /var/run/php-fpm7.sock|g" \ 
        -e "s|;listen\.owner\s*=\s*|listen.owner = |g" \ 
        -e "s|;listen\.group\s*=\s*|listen.group = |g" \ 
        -e "s|;listen\.mode\s*=\s*|listen.mode = |g" \ 
        -i /etc/php7/php-fpm.d/www.conf

EXPOSE 80 
VOLUME ["/var/dokuwiki-storage"]

CMD /start.sh
