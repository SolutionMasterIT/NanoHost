#!/bin/bash
set -e

echo "🚀 Starting Multi-Domain Development Environment..."

# Várakozás az adatbázisra SSL kényszerítés nélkül
echo "⏳ Waiting for database (SSL disabled for ping)..."
while ! mysqladmin ping -h"$DB_HOST" -uroot -p"$MYSQL_ROOT_PASSWORD" --silent --ssl=0; do
    sleep 1
done
echo "✅ Database is ready!"

# Domain lista feldolgozása
if [ -z "$DOMAINS" ]; then
    echo "❌ ERROR: DOMAINS environment variable is not set!"
    exit 1
fi

IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"

# Alapértelmezett domain beállítása
if [ -z "$DEFAULT_DOMAIN" ]; then
    DEFAULT_DOMAIN="${DOMAIN_ARRAY[0]}"
fi

echo "📋 Configured domains: ${DOMAINS}"
echo "🏠 Default domain: ${DEFAULT_DOMAIN}"

# Könyvtárak létrehozása
echo "📁 Creating domain directories..."
for domain in "${DOMAIN_ARRAY[@]}"; do
    domain=$(echo "$domain" | xargs) # trim
    
    if [ ! -d "/var/www/html/$domain" ]; then
        echo "  ➕ Creating directory for: $domain"
        mkdir -p "/var/www/html/$domain"
        chown -R www-data:www-data "/var/www/html/$domain"
    else
        echo "  ✓ Directory exists: $domain"
    fi
done

# SSL tanúsítványok generálása
echo "🔐 Generating SSL certificates..."
/scripts/generate-ssl.sh

# VirtualHost konfigurációk generálása
echo "🌐 Generating Apache VirtualHosts..."
/scripts/generate-vhosts.sh

# Apache konfiguráció újratöltése
echo "🔄 Reloading Apache configuration..."
apache2ctl configtest
service apache2 reload || true

# Adatbázisok létrehozása (--ssl=0)
echo "🗄️ Setting up databases..."
/scripts/setup-databases.sh

# Hosts fájl információ
echo ""
echo "================================================"
echo "✅ Setup complete!"
echo "================================================"
echo ""
echo "📝 Add these entries to your /etc/hosts file:"
echo ""
for domain in "${DOMAIN_ARRAY[@]}"; do
    domain=$(echo "$domain" | xargs)
    echo "127.0.0.1    $domain"
done
echo ""
echo "🌐 Access your sites at:"
for domain in "${DOMAIN_ARRAY[@]}"; do
    domain=$(echo "$domain" | xargs)
    echo "  https://$domain"
done
echo ""
echo "🗄️ phpMyAdmin: http://localhost:8080"
echo "    Username: root"
echo "    Password: $MYSQL_ROOT_PASSWORD"
echo ""
echo "================================================"

# Apache indítása
exec apache2-foreground