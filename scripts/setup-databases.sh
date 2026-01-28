#!/bin/bash
set -e

# Ellenőrizzük, hogy a szükséges változók megvannak-e
if [ -z "$DOMAINS" ]; then
    echo "❌ ERROR: DOMAINS environment variable is not set in setup-databases.sh!"
    exit 1
fi

IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"

for domain in "${DOMAIN_ARRAY[@]}"; do
    domain=$(echo "$domain" | xargs)
    
    # Adatbázis név: domain pontok helyett underscore
    DB_NAME=$(echo "$domain" | sed 's/\./_/g')
    
    echo "  🗄️ Setting up database: $DB_NAME"
	
    # Adatbázis létrehozása SSL kikapcsolással (--ssl=0)
    # A MariaDB 11+ megkövetelheti az SSL-t a klienstől, ha nincs explicit tiltva
    if mysql -h"$DB_HOST" -uroot -p"$MYSQL_ROOT_PASSWORD" --ssl=0 -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null; then
        echo "  ✅ Database ready: $DB_NAME"
    else
        # Ha a CREATE DATABASE hibát dob, megpróbálunk egy sima belépést ellenőrzésnek
        if mysql -h"$DB_HOST" -uroot -p"$MYSQL_ROOT_PASSWORD" --ssl=0 -e "USE \`${DB_NAME}\`;" 2>/dev/null; then
            echo "  ✓ Database already exists and is accessible: $DB_NAME"
        else
            echo "  ❌ ERROR: Could not create or access database: $DB_NAME"
        fi
    fi
done

echo "✅ All databases configured"