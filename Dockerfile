FROM ubuntu:18.04

ENV DOWNLOAD_DIR /root/download
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS \
	openssl \
	net-tools \
	git \
	locales \
	sudo \
	dumb-init \
	vim \
	curl \
	wget \
	zip \
	unzip \
	libzip-dev \
    libicu-dev

## Create download folder
RUN mkdir -p $DOWNLOAD_DIR && cd $DOWNLOAD_DIR

## Install Packages

# Install code-server
RUN cd $DOWNLOAD_DIR && wget -q --no-check-certificate https://github.com/cdr/code-server/releases/download/1.1156-vsc1.33.1/code-server1.1156-vsc1.33.1-linux-x64.tar.gz
RUN cd $DOWNLOAD_DIR && tar -zxf code-server1.1156-vsc1.33.1-linux-x64.tar.gz
RUN mv $DOWNLOAD_DIR/code-server1.1156-vsc1.33.1-linux-x64/code-server /usr/local/bin/code-server

# Install php7.1.2
RUN cd $DOWNLOAD_DIR && wget -q --no-check-certificate https://www.php.net/distributions/php-7.1.28.tar.xz
RUN cd $DOWNLOAD_DIR && ls -al && tar -xf php-7.1.28.tar.xz
RUN sha256sum $DOWNLOAD_DIR/php-7.1.28.tar.xz
RUN cd $DOWNLOAD_DIR/php-7.1.28 \
    &&  ./configure \
    --with-curl \
    --with-mysqli \
    --with-openssl \
    --with-pdo-mysql \
    --with-zlib \
    --enable-bcmath \
    --enable-exif \
    --enable-fpm \
    --enable-mbstring \
    --enable-intl \
    --enable-zip \
    && make && make install

#    && wget -q http://nginx.org/download/nginx-1.8.1.tar.gz \
#    && tar -zxf code-server1.1156-vsc1.33.1-linux-x64.tar.gz \
#    && tar -zxf php-7.1.27.tar.gz \
#    && tar -zxf nginx-1.8.1.tar.gz
#
## Install php7.1.2
#RUN cd $DOWNLOAD_DIR/php-7.1.27 \
#    &&  ./configure \
#    --with-curl \
#    --with-mysqli \
#    --with-openssl \
#    --with-pdo-mysql \
#    --with-zlib \
#    --enable-bcmath \
#    --enable-exif \
#    --enable-fpm \
#    --enable-mbstring \
#    --enable-intl \
#    --enable-zip


# Install Nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/ && rm -rf /root/downloads

## Run services


## Start code-server

RUN locale-gen en_US.UTF-8
# We unfortunately cannot use update-locale because docker will not use the env variables
# configured in /etc/default/locale so we need to set it manually.
ENV LC_ALL=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder && \
	echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER coder
# We create first instead of just using WORKDIR as when WORKDIR creates, the user is root.
RUN mkdir -p /home/coder/project

WORKDIR /home/coder/project

# This assures we have a volume mounted even if the user forgot to do bind mount.
# So that they do not lose their data if they delete the container.
VOLUME [ "/home/coder/project" ]

EXPOSE 8443

ENTRYPOINT ["dumb-init", "code-server"]

