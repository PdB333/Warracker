#!/bin/bash
set -euo pipefail

echo "=== Warracker Startup ==="

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Database connection check (with retry)
log "Waiting for database connection..."
for i in {1..30}; do
    if pg_isready -h "${DB_HOST:-localhost}" -p "${DB_PORT:-5432}" -U "${DB_USER:-postgres}" > /dev/null 2>&1; then
        log "Database is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        log "ERROR: Database not available after 30 attempts"
        exit 1
    fi
    sleep 2
done

# Migrations and permissions
log "Running database migrations..."
python /app/migrations/apply_migrations.py

log "Fixing permissions (database and upload folder)..."
python /app/fix_permissions.py

# Translation compilation
log "Compiling translations..."
cd /app
pybabel compile -d locales 2>/dev/null || log "Warning: Translation compilation failed"

# Nginx configuration (create temp file, root will move it)
log "Preparing nginx configuration..."
EFFECTIVE_SIZE="${NGINX_MAX_BODY_SIZE_VALUE:-32M}"
if ! echo "${EFFECTIVE_SIZE}" | grep -Eq "^[0-9]+[mMkKgG]?$"; then
    log "Warning: Invalid NGINX_MAX_BODY_SIZE_VALUE. Using default 32M"
    EFFECTIVE_SIZE="32M"
fi

SERVER_NAME="${NGINX_SERVER_NAME:-localhost}"
HTTPS_LISTEN_DIRECTIVES=""
HTTPS_SSL_DIRECTIVES=""
ENABLE_HTTPS="$(echo "${NGINX_ENABLE_HTTPS:-false}" | tr '[:upper:]' '[:lower:]')"

if [ "${ENABLE_HTTPS}" = "true" ]; then
    CERT_PATH="${NGINX_SSL_CERT_PATH:-/etc/nginx/certs/fullchain.pem}"
    KEY_PATH="${NGINX_SSL_KEY_PATH:-/etc/nginx/certs/privkey.pem}"

    if [ ! -f "${CERT_PATH}" ] || [ ! -f "${KEY_PATH}" ]; then
        log "HTTPS enabled but certificate/key not found. Generating fallback self-signed certificate."
        CERT_PATH="/tmp/warracker-selfsigned.crt"
        KEY_PATH="/tmp/warracker-selfsigned.key"

        if command -v openssl >/dev/null 2>&1; then
            if ! openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 \
                -keyout "${KEY_PATH}" \
                -out "${CERT_PATH}" \
                -subj "/CN=${SERVER_NAME}" \
                -addext "subjectAltName=DNS:${SERVER_NAME}" >/dev/null 2>&1; then
                openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 \
                    -keyout "${KEY_PATH}" \
                    -out "${CERT_PATH}" \
                    -subj "/CN=${SERVER_NAME}" >/dev/null 2>&1
            fi
            chmod 600 "${KEY_PATH}"
        else
            log "ERROR: openssl is not available and no TLS certificates were found."
            exit 1
        fi
    fi

    HTTPS_LISTEN_DIRECTIVES="listen 443 ssl; listen [::]:443 ssl;"
    HTTPS_SSL_DIRECTIVES="ssl_certificate ${CERT_PATH}; ssl_certificate_key ${KEY_PATH};"
    log "HTTPS enabled for server_name=${SERVER_NAME}"
else
    log "HTTPS disabled. Serving HTTP only."
fi

escaped_server_name="$(printf '%s' "${SERVER_NAME}" | sed 's/[&|]/\\&/g')"
escaped_https_listen="$(printf '%s' "${HTTPS_LISTEN_DIRECTIVES}" | sed 's/[&|]/\\&/g')"
escaped_https_ssl="$(printf '%s' "${HTTPS_SSL_DIRECTIVES}" | sed 's/[&|]/\\&/g')"

sed \
    -e "s|__NGINX_MAX_BODY_SIZE_CONFIG_VALUE__|${EFFECTIVE_SIZE}|g" \
    -e "s|__NGINX_SERVER_NAME__|${escaped_server_name}|g" \
    -e "s|__NGINX_HTTPS_LISTEN__|${escaped_https_listen}|g" \
    -e "s|__NGINX_HTTPS_SSL__|${escaped_https_ssl}|g" \
    /etc/nginx/conf.d/default.conf.template > /tmp/nginx-default.conf

log "Nginx config prepared (size: ${EFFECTIVE_SIZE})"
log "Setup completed successfully!"

# Execute the CMD (supervisor) by replacing this shell process
log "Starting supervisor..."
exec "$@"
