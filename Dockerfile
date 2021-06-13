FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NGINX_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# install packages
RUN \
 apk add --no-cache --upgrade \
	curl && \
 if [ -z ${NGINX_VERSION+x} ]; then \
	NGINX_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
	&& awk '/^P:nginx$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
 fi && \
 apk add --no-cache --upgrade \
  gnupg \
  fail2ban \
	memcached \
	nginx==${NGINX_VERSION} \
	nginx-mod-http-brotli==${NGINX_VERSION} \
	nginx-mod-http-dav-ext==${NGINX_VERSION} \
	nginx-mod-http-echo==${NGINX_VERSION} \
	nginx-mod-http-fancyindex==${NGINX_VERSION} \
	nginx-mod-http-geoip==${NGINX_VERSION} \
	nginx-mod-http-geoip2==${NGINX_VERSION} \
	nginx-mod-http-headers-more==${NGINX_VERSION} \
	nginx-mod-http-image-filter==${NGINX_VERSION} \
	nginx-mod-http-nchan==${NGINX_VERSION} \
	nginx-mod-http-perl==${NGINX_VERSION} \
	nginx-mod-http-redis2==${NGINX_VERSION} \
	nginx-mod-http-set-misc==${NGINX_VERSION} \
	nginx-mod-http-upload-progress==${NGINX_VERSION} \
	nginx-mod-http-xslt-filter==${NGINX_VERSION} \
	nginx-mod-mail==${NGINX_VERSION} \
	nginx-mod-rtmp==${NGINX_VERSION} \
	nginx-mod-stream==${NGINX_VERSION} \
	nginx-mod-stream-geoip==${NGINX_VERSION} \
	nginx-mod-stream-geoip2==${NGINX_VERSION} \
	nginx-vim==${NGINX_VERSION} \
	php7-bcmath \
	php7-bz2 \
	php7-ctype \
	php7-curl \
	php7-dom \
	php7-exif \
	php7-ftp \
	php7-gd \
	php7-gmp \
	php7-iconv \
	php7-imap \
	php7-intl \
	php7-ldap \
	php7-mcrypt \
	php7-memcached \
	php7-mysqli \
	php7-mysqlnd \
	php7-opcache \
	php7-pdo_mysql \
	php7-pdo_odbc \
	php7-pdo_pgsql \
	php7-pdo_sqlite \
	php7-pear \
	php7-pecl-apcu \
	php7-pecl-mailparse \
	php7-pecl-redis \
	php7-pgsql \
	php7-phar \
	php7-posix \
	php7-soap \
	php7-sockets \
	php7-sodium \
	php7-sqlite3 \
	php7-tokenizer \
	php7-xml \
	php7-xmlreader \
	php7-xmlrpc \
	php7-xsl \
	php7-zip && \
 echo "**** configure nginx ****" && \
 rm -f /etc/nginx/conf.d/default.conf && \
 sed -i \
	's|include /config/nginx/site-confs/\*;|include /config/nginx/site-confs/\*;\n\t#Removed lua. Do not remove this comment|g' \
	/defaults/nginx.conf
 echo "**** remove unnecessary fail2ban filters ****" && \
 rm \
  /etc/fail2ban/jail.d/alpine-ssh.conf && \
 echo "**** copy fail2ban default action and filter to /default ****" && \
 mkdir -p /defaults/fail2ban && \
 mv /etc/fail2ban/action.d /defaults/fail2ban/ && \
 mv /etc/fail2ban/filter.d /defaults/fail2ban/ && \

# add local files
COPY root/ /
