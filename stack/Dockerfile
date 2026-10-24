FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    libpng-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install redis \
    && docker-php-ext-enable redis

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN { \
    echo "xdebug.mode=debug"; \
    echo "xdebug.start_with_request=trigger"; \
    echo "xdebug.client_host=host.docker.internal"; \
    echo "xdebug.client_port=9003"; \
    } > /usr/local/etc/php/conf.d/99-xdebug.ini

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

RUN docker-php-ext-install -j"$(nproc)" \
    pdo \
    pdo_mysql \
    zip \
    mbstring \
    bcmath \
    intl \
    gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY php-custom.ini /usr/local/etc/php/conf.d/zz-custom.ini

ENV COMPOSER_PROCESS_TIMEOUT=1800

WORKDIR /var/www

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
