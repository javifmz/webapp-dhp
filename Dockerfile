FROM alpine:3.11
RUN apk update && apk upgrade && \
    echo @3.11 http://nl.alpinelinux.org/alpine/v3.11/community >> /etc/apk/repositories && \
    echo @3.11 http://nl.alpinelinux.org/alpine/v3.11/main >> /etc/apk/repositories && \
    apk --no-cache add nginx nano less curl openjdk8 \
        php7 php7-fpm php7-opcache php7-json php7-pdo php7-pdo_mysql php-iconv php-mbstring \
        php7-dom php7-ctype php7-curl php7-gd php7-intl php7-mcrypt php7-mysqlnd php7-posix \
        php7-session php7-tidy php7-xml php7-zip
COPY ./docker-entrypoint.sh /
COPY ./docker-nginx.conf /etc/nginx/conf.d/nginx.conf
RUN mv /docker-entrypoint.sh /entrypoint.sh && \
    adduser -D -g 'www' www && \
    mkdir /www && mkdir /www/web && mkdir /www/api && mkdir /www/api/public && mkdir /app && mkdir /app/web-base && mkdir /run/nginx/ && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www && \
    rm /etc/nginx/conf.d/default.conf && \
    chmod +x /entrypoint.sh && \
    echo 'sleep infinity' > /app/start.sh && \
    touch /app/init.sh && \
    { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
		echo 'decorate_workers_output = no'; \
	} > /etc/php7/php-fpm.d/docker.conf && \
    { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} > /etc/php7/php-fpm.d/zz-docker.conf && \
    echo 'Web works!' > /app/web-base/index.html && \
    echo 'API works!<?php error_log("API error log works!"); ?>' > /www/api/public/index.php
EXPOSE 80
STOPSIGNAL SIGTERM
ENTRYPOINT [ "/entrypoint.sh" ]
