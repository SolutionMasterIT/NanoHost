# Legfrissebb PHP 8.4 (2026 január)
FROM php:8.4-apache

LABEL maintainer="dev@localhost"
LABEL description="Multi-domain PHP development environment"

# Telepítés előkészítés
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libwebp-dev \
    libavif-dev \
    mariadb-client \
    zip \
    unzip \
    git \
    curl \
    vim \
    openssl \
	dos2unix \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-avif \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    zip \
    intl \
    mbstring \
    exif \
    opcache \
    bcmath \
    soap \
    xml

# Apache modulok
RUN a2enmod rewrite ssl headers expires deflate

# Composer telepítés
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# WP-CLI telepítés
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Munkamkönyvtár
WORKDIR /var/www/html

# Apache konfiguráció
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Jogosultságok
RUN chown -R www-data:www-data /var/www/html

# Szkriptek futtathatóvá tétele
RUN mkdir -p /scripts
COPY scripts/ /scripts/
#!!! Ez kritikus, ha Windows alatt szerkesztetted a fájlokat:
RUN dos2unix /scripts/*.sh && chmod +x /scripts/*.sh

EXPOSE 80 443

# Fontos: Ha a docker-compose-ban van entrypoint, az felülírja ezt.
# De jó gyakorlat itt hagyni alapértelmezettnek, lehet helyette pl. CMD ["apache2-foreground"] 
CMD ["/scripts/entrypoint.sh"]