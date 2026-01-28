#!/bin/bash
set -e

SSL_DIR="/etc/apache2/ssl"
mkdir -p "$SSL_DIR"

IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"

for domain in "${DOMAIN_ARRAY[@]}"; do
    domain=$(echo "$domain" | xargs)
    
    CERT_FILE="$SSL_DIR/${domain}.crt"
    KEY_FILE="$SSL_DIR/${domain}.key"
    
    if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
        echo "  🔐 Generating SSL certificate for: $domain"
        
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout "$KEY_FILE" \
            -out "$CERT_FILE" \
            -subj "/C=HU/ST=Hungary/L=Budapest/O=Development/CN=$domain" \
            -addext "subjectAltName=DNS:$domain,DNS:www.$domain" \
            2>/dev/null
        
        chmod 600 "$KEY_FILE"
        chmod 644 "$CERT_FILE"
        
        echo "  ✅ SSL certificate created for: $domain"
    else
        echo "  ✓ SSL certificate exists: $domain"
    fi
done

echo "✅ SSL certificates ready"