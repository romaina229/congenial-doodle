# Stage 1: Build des assets frontend
FROM node:20-alpine AS node-builder

WORKDIR /app

# Copier les fichiers de dépendances Node
COPY package*.json ./

# Installer les dépendances Node
RUN npm ci --only=production

# Copier les fichiers nécessaires pour le build
COPY resources ./resources
COPY vite.config.js ./
COPY tailwind.config.js ./

# Build des assets
RUN npm run build

# Stage 2: Setup PHP et Composer
FROM php:8.2-fpm-alpine AS php-builder

# Installer les dépendances système nécessaires
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    postgresql-dev \
    mysql-dev \
    icu-dev

# Installer les extensions PHP
RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copier les fichiers de dépendances PHP
COPY composer.json composer.lock ./

# Installer les dépendances PHP (production uniquement)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --prefer-dist

# Stage 3: Image finale
FROM php:8.2-fpm-alpine

# Installer les dépendances runtime nécessaires
RUN apk add --no-cache \
    nginx \
    supervisor \
    libpng \
    oniguruma \
    libxml2 \
    libzip \
    postgresql-libs \
    mysql-client \
    icu-libs \
    curl

# Installer les extensions PHP
RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl

# Créer l'utilisateur www
RUN addgroup -g 1000 www && adduser -u 1000 -G www -s /bin/sh -D www

WORKDIR /var/www/html

# Copier les dépendances PHP depuis le builder
COPY --from=php-builder --chown=www:www /app/vendor ./vendor

# Copier les fichiers de l'application
COPY --chown=www:www . .

# Copier les assets buildés depuis le node-builder
COPY --from=node-builder --chown=www:www /app/public/build ./public/build

# Copier les fichiers de configuration
COPY --chown=www:www apache.conf /etc/apache2/sites-available/000-default.conf

# Créer les répertoires nécessaires
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    public/storage

# Définir les permissions
RUN chown -R www:www /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Copier le fichier de configuration Nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copier le fichier de configuration Supervisor
COPY supervisord.conf /etc/supervisord.conf

# Optimiser l'application
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Exposer le port
EXPOSE 8080

# Script de démarrage
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
