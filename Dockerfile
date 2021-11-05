FROM php:5.6-apache

MAINTAINER Khue Quang Nguyen <khuenq.devmail@gmail.com>

# Install System Dependencies

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	software-properties-common \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
	libfreetype6-dev \
	libicu-dev \
        libssl-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libedit-dev \
	libedit2 \
	libxslt1-dev \
	apt-utils \
	gnupg \
	redis-tools \
	mariadb-client \
	git \
	vim \
	wget \
	curl \
	lynx \
	psmisc \
	unzip \
	htop \
	nano \
	libsodium-dev \
	tar \
	cron \
	bash-completion \
	libonig-dev \
	libzip-dev \
	&& apt-get clean

# Install Magento Dependencies

RUN echo "Install PHP extensions" \
	docker-php-ext-configure \
        gd --with-freetype --with-jpeg; \
        docker-php-ext-install \
        opcache \
        gd \
        bcmath \
        intl \
        mbstring \
        pdo_mysql \
        soap \
        xsl \
        sockets \
        zip

ENV PATH="/var/www/.composer/vendor/bin/:${PATH}"

RUN wget https://files.magerun.net/n98-magerun.phar \
    && chmod +x ./n98-magerun.phar \
    && mv ./n98-magerun.phar ./n98
    && cp ./n98 /usr/local/bin

# Configuring system

ADD .docker/config/php.ini /usr/local/etc/php/php.ini
ADD .docker/config/magento.conf /etc/apache2/sites-available/magento.conf
ADD .docker/config/custom-xdebug.ini /usr/local/etc/php/conf.d/custom-xdebug.ini
COPY .docker/bin/* /usr/local/bin/
COPY .docker/users/* /var/www/
RUN chmod +x /usr/local/bin/*
RUN ln -s /etc/apache2/sites-available/magento.conf /etc/apache2/sites-enabled/magento.conf

RUN curl -o /etc/bash_completion.d/m2install-bash-completion https://raw.githubusercontent.com/yvoronoy/m2install/master/m2install-bash-completion
RUN curl -o /etc/bash_completion.d/n98-magerun2.phar.bash https://raw.githubusercontent.com/netz98/n98-magerun2/master/res/autocompletion/bash/n98-magerun2.phar.bash
RUN echo "source /etc/bash_completion" >> /root/.bashrc
RUN echo "source /etc/bash_completion" >> /var/www/.bashrc

RUN chmod 777 -Rf /var/* /var/www /var/www/.* \
	&& chown -Rf www-data:www-data /var/www /var/www/.* \
	&& usermod -u 1000 www-data \
	&& chsh -s /bin/bash www-data\
	&& a2enmod rewrite \
	&& a2enmod headers

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd-jis-conv
RUN docker-php-ext-install -j$(nproc) gd

VOLUME /var/www/html
WORKDIR /var/www/html
