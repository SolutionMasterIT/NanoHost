#!/bin/bash
set -e

VHOST_DIR="/etc/apache2/sites-available"
VHOST_ENABLED="/etc/apache2/sites-enabled"

# Régi konfigurációk törlése (kivéve default)
rm -f $VHOST_DIR/00*.conf
rm -f $VHOST_ENABLED/00*.conf

IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"

counter=1
for domain in "${DOMAIN_ARRAY[@]}"; do
    domain=$(echo "$domain" | xargs)
    
    # Fájl név sorszámozással (rendezés miatt)
    CONF_FILE="$VHOST_DIR/00${counter}-${domain}.conf"
    
    echo "  Generating VirtualHost for: $domain"
    
    cat > "$CONF_FILE" <<EOF
# HTTP (80) - Redirect to HTTPS
<VirtualHost *:80>
    ServerName $domain
    ServerAlias www.$domain
    
    DocumentRoot /var/www/html/$domain
    
    # Redirect minden kérést HTTPS-re
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}\$1 [R=301,L]
    
    ErrorLog \${APACHE_LOG_DIR}/${domain}-error.log
    CustomLog \${APACHE_LOG_DIR}/${domain}-access.log combined
</VirtualHost>

# HTTPS (443)
<VirtualHost *:443>
    ServerName $domain
    ServerAlias www.$domain
    
    DocumentRoot /var/www/html/$domain
    
    # SSL konfiguráció
    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/${domain}.crt
    SSLCertificateKeyFile /etc/apache2/ssl/${domain}.key
    
    # Directory beállítások
    <Directory /var/www/html/$domain>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # PHP konfiguráció
    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>
    
    # Compression
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
    </IfModule>
    
    # Security headers
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-XSS-Protection "1; mode=block"
    
    ErrorLog \${APACHE_LOG_DIR}/${domain}-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/${domain}-ssl-access.log combined
</VirtualHost>
EOF
    
    # Site engedélyezése
    ln -sf "$CONF_FILE" "$VHOST_ENABLED/00${counter}-${domain}.conf"
    
    ((counter++))
done

# Default site letiltása
a2dissite 000-default.conf || true
a2dissite default-ssl.conf || true

echo "✅ VirtualHost configurations generated"