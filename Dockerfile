FROM ubuntu:focal

ARG LOCALE=en_US

RUN apt-get update && \
    apt-get install -y ca-certificates locales curl iputils-ping net-tools vim-tiny nginx supervisor dumb-init \
        php7.4-fpm php7.4-cli php7.4-bcmath php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mbstring \
        php7.4-redis php7.4-pgsql php7.4-mysql php7.4-opcache php7.4-igbinary php7.4-soap php7.4-xml php7.4-zip && \
    localedef -i ${LOCALE} -c -f UTF-8 -A /usr/share/locale/locale.alias ${LOCALE}.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=$LOCALE.UTF-8
ENV LC_ALL=$LOCALE.UTF-8

COPY ./assets /app/assets/

RUN mkdir -p /app/src && chown -R 1000:0 /app && \
    chmod +x /app/assets/entrypoint.sh && chmod +x /app/assets/supervisord-helper.py && \
    ln -s /app/assets/30-custom.ini /etc/php/7.4/cli/conf.d/30-custom.ini && \
    ln -s /app/assets/30-custom.ini /etc/php/7.4/fpm/conf.d/30-custom.ini && \
    cp -rf /app/assets/nginx.conf /etc/nginx/nginx.conf && \
    mkdir -p /etc/nginx/nginx.conf.d && cp /app/assets/nginx.conf.d/*.conf /etc/nginx/nginx.conf.d/ && \
    mkdir -p /var/log/nginx && chown -R 1000:0 /var/log/nginx && chmod 775 /var/log/nginx && \
    mkdir -p /tmp/opcache /tmp/sessions && chown 1000:0 /tmp/opcache /tmp/sessions && chmod 775 /tmp/opcache /tmp/sessions && \
    chmod g+w /etc/passwd /app/assets/30-custom.ini /app/assets && \
    echo "app:x:1000:0:app user:/app:/usr/sbin/nologin" >> /etc/passwd

WORKDIR /app/src
USER 1000

EXPOSE 8080 8081

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/app/assets/entrypoint.sh"]

CMD []
