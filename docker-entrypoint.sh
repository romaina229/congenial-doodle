#!/bin/sh

set -e

# Attendre que la base de données soit prête (si nécessaire)
if [ -n "$DB_HOST" ]; then
    echo "Waiting for database..."
    until nc -z -v -w30 $DB_HOST ${DB_PORT:-3306}
    do
        echo "Waiting for database connection..."
        sleep 5
    done
    echo "Database is ready!"
fi

# Créer le lien symbolique du storage si nécessaire
if [ ! -L /var/www/html/public/storage ]; then
    php artisan storage:link
fi

# Exécuter les migrations si AUTO_MIGRATE est défini
if [ "$AUTO_MIGRATE" = "true" ]; then
    echo "Running migrations..."
    php artisan migrate --force --no-interaction
fi

# Nettoyer les caches si nécessaire
if [ "$CLEAR_CACHE" = "true" ]; then
    echo "Clearing caches..."
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
fi

# Optimiser l'application
if [ "$OPTIMIZE" = "true" ]; then
    echo "Optimizing application..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Créer les répertoires de logs pour supervisor
mkdir -p /var/log/supervisor

echo "Starting application..."

# Exécuter la commande passée au conteneur
exec "$@"
