# Warracker (Fork)

Warranty tracking app for teams and individuals.

This repository is a fork of the original project:
- Upstream: https://github.com/sassanix/Warracker
- This fork: https://github.com/PdB333/Warracker

## Fork Notice

This fork keeps upstream Warracker as the base and adds production-focused fixes and custom behavior used in real deployments.

Please credit the upstream project and keep AGPL-3.0 license terms when reusing or redistributing.

## What This App Does

Warracker helps you:
- track warranties and expiration dates
- store product-related documents
- manage users and roles
- send expiration notifications (email and/or Apprise)
- use OIDC SSO (Keycloak, Google, etc.)

## Fork-Specific Additions

This fork includes all upstream functionality plus the following important additions.

### Reliability and Account Behavior

- warranties are preserved when a user is deleted (detached/orphan mode)
- orphan warranties are visible in global/admin context with `[Deleted User]` marker
- orphan warranty notification fallback goes to active owner/admin recipient
- case-insensitive email uniqueness hardening
- safer session behavior with server-side session id checks

### OIDC and Admin Mapping

- improved OIDC group/role extraction logic for providers like Keycloak
- support for `OIDC_ADMIN_GROUP` mapping
- compatibility with legacy setting key `admin_oidc_group`
- safer callback token handoff (`#token=` fragment flow)

### Notification Improvements

- additional notification recipients on warranties
- support for multiple additional emails per warranty (comma-separated storage)
- separate email templates on disk (editable without Python code changes):
  - `backend/email_templates/expiration_subject.txt`
  - `backend/email_templates/expiration_body.txt`
  - `backend/email_templates/expiration_body.html`

### UI / i18n / UX

- language switching robustness improvements
- translation fallback behavior hardened
- service worker caching behavior improved for language/update consistency
- missing translation keys filled for new notification-email UI

### HTTPS in Container

- optional TLS termination directly inside the app container via env flags
- configurable cert/key paths
- works with self-signed or internal CA certs when correctly mounted

## Tech Stack

- Frontend: HTML, CSS, JavaScript
- Backend: Python (Flask)
- Database: PostgreSQL
- Web server: Nginx
- Process: Gunicorn + Supervisor
- Container: Docker Compose

## Quick Start

### Prerequisites

- Docker
- Docker Compose plugin (`docker compose`)

### 1) Clone and prepare env

```bash
git clone https://github.com/PdB333/Warracker.git
cd Warracker
cp Docker/.env.example .env
```

Edit `.env` for your environment.

### 2) Start stack

```bash
docker compose up -d --build
docker compose ps
```

### 3) Access app

- HTTP mode (default compose mapping): `http://<host>:8005`
- HTTPS mode (if enabled in env and certs mounted): `https://<host>:443`

## Docker Compose Notes

Current compose file exposes:
- app container on host port `8005` -> container port `80`
- postgres internal service `warrackerdb:5432`

If you need host port `443`, adjust `docker-compose.yml` ports mapping accordingly.

## Environment Variables Reference

Use `Docker/.env.example` as baseline. The list below includes variables used by this fork and runtime.

## Database and Core App

| Variable | Default | Purpose |
| --- | --- | --- |
| `DB_HOST` | `warrackerdb` | PostgreSQL host |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_NAME` | `warranty_db` | App DB name |
| `DB_USER` | `warranty_user` | App DB user |
| `DB_PASSWORD` | `warranty_password` | App DB password |
| `DB_ADMIN_USER` | `warracker_admin` | Admin DB user for setup/migrations |
| `DB_ADMIN_PASSWORD` | `change_this_password_in_production` | Admin DB password |
| `SECRET_KEY` | `your_very_secret_flask_key_change_me` | Flask/JWT secret |
| `JWT_EXPIRATION_HOURS` | `24` | JWT expiration window |
| `PYTHONUNBUFFERED` | `1` | Unbuffered python logs |
| `WARRACKER_MEMORY_MODE` | `optimized` | Runtime memory profile (`optimized`, `ultra-light`, `performance`) |

## Postgres Container

| Variable | Default | Purpose |
| --- | --- | --- |
| `POSTGRES_DB` | `warranty_db` | Initial postgres DB |
| `POSTGRES_USER` | `warranty_user` | Postgres user |
| `POSTGRES_PASSWORD` | `warranty_password` | Postgres password |

## URL and Upload Settings

| Variable | Default | Purpose |
| --- | --- | --- |
| `FRONTEND_URL` | `http://localhost:8005` | Public frontend URL for redirects |
| `APP_BASE_URL` | `http://localhost:8005` | Base URL used in app links/emails |
| `MAX_UPLOAD_MB` | `32` in example | Max backend upload size |
| `NGINX_MAX_BODY_SIZE_VALUE` | `32M` in example | Nginx request body limit |

## SMTP / Mail

| Variable | Default | Purpose |
| --- | --- | --- |
| `SMTP_HOST` | `smtp.gmail.com` in example | SMTP server host |
| `SMTP_PORT` | `587` in example | SMTP server port |
| `SMTP_USERNAME` | empty/example value | SMTP auth username |
| `SMTP_PASSWORD` | empty/example value | SMTP auth password |
| `SMTP_PASSWORD_FILE` | unset | Optional file path for SMTP password secret |
| `SMTP_USE_TLS` | `true` | Use STARTTLS |
| `SMTP_USE_SSL` | `false` | Use direct SSL SMTP |
| `SMTP_SENDER_EMAIL` | `noreply@warracker.com` | Sender for account/auth emails |
| `SMTP_FROM_ADDRESS` | fallback to username | Sender for warranty notification emails |

## OIDC / SSO

| Variable | Default | Purpose |
| --- | --- | --- |
| `OIDC_ENABLED` | `false` | Enable OIDC login |
| `OIDC_ONLY_MODE` | `false` | Force OIDC-only auth mode |
| `OIDC_PROVIDER_NAME` | `oidc` | Provider name |
| `OIDC_CLIENT_ID` | empty | OIDC client id |
| `OIDC_CLIENT_SECRET` | empty | OIDC client secret |
| `OIDC_CLIENT_SECRET_FILE` | unset | Optional file path for OIDC client secret |
| `OIDC_ISSUER_URL` | empty | OIDC issuer URL (discovery endpoint base) |
| `OIDC_SCOPE` | `openid email profile` | OIDC scopes |
| `OIDC_ADMIN_GROUP` | empty | Group/role name mapped to admin |
| `OIDC_FORCE_HTTPS` | `false` | Force https callback URL generation |

## Apprise Notifications

| Variable | Default | Purpose |
| --- | --- | --- |
| `APPRISE_ENABLED` | `false` | Enable Apprise channel |
| `APPRISE_URLS` | empty | Comma-separated Apprise destinations |
| `APPRISE_EXPIRATION_DAYS` | `7,30` | Trigger days before expiration |
| `APPRISE_NOTIFICATION_TIME` | `09:00` | Daily send time |
| `APPRISE_TITLE_PREFIX` | `[Warracker]` | Notification title prefix |

## HTTPS / TLS (Optional In-Container TLS)

| Variable | Default | Purpose |
| --- | --- | --- |
| `NGINX_ENABLE_HTTPS` | `false` | Enable HTTPS listener in container |
| `NGINX_SERVER_NAME` | `localhost` | Server name in nginx config |
| `NGINX_SSL_CERT_PATH` | `/etc/nginx/certs/fullchain.pem` | TLS cert path in container |
| `NGINX_SSL_KEY_PATH` | `/etc/nginx/certs/privkey.pem` | TLS key path in container |
| `REQUESTS_CA_BUNDLE` | unset | CA bundle for outbound python requests |
| `SSL_CERT_FILE` | unset | OpenSSL CA bundle path for python |

## Dev / Debug

| Variable | Default | Purpose |
| --- | --- | --- |
| `FLASK_ENV` | `production` | Flask environment |
| `FLASK_DEBUG` | `false` | Debug mode |
| `FLASK_RUN_PORT` | `5000` | Local flask run port |

## OIDC Setup Checklist (Keycloak Example)

1. Set:
   - `OIDC_ENABLED=true`
   - `OIDC_CLIENT_ID=...`
   - `OIDC_CLIENT_SECRET=...`
   - `OIDC_ISSUER_URL=https://<keycloak>/realms/<realm>`
   - `OIDC_SCOPE=openid email profile groups`
2. Configure Keycloak mappers so groups/roles are present in token/userinfo.
3. If using group-based admin mapping, set `OIDC_ADMIN_GROUP=<group_name>`.
4. Ensure container trusts your IdP certificate chain (internal CA if needed).

## Notification Behavior (Important)

- Standard email notifications go to warranty owner email.
- Additional notification emails can be attached to a warranty.
- Multiple additional recipients are supported in this fork.
- If owner account is removed and warranty is detached, notification fallback can target owner/admin recipient logic.

## Migrations

Migrations live in `backend/migrations` and are applied on container startup.

Notable recent migrations:
- `051_create_email_change_tokens_table.sql`
- `052_enforce_case_insensitive_email_uniqueness.sql`
- `053_add_additional_notification_email_to_warranties.sql`
- `054_expand_additional_notification_email_to_text.sql`

## Contributing

Contributions are welcome.

Recommended flow:

```bash
git checkout -b feature/my-change
git commit -m "feat: describe change"
git push origin feature/my-change
```

Then open a PR.

If your change should also exist upstream, please keep compatibility with upstream architecture where possible.

## Upstream Sync (Maintainers)

If you maintain this fork and want to sync with upstream:

```bash
git remote add upstream https://github.com/sassanix/Warracker.git
git fetch upstream
git checkout main
git merge upstream/main
```

Resolve conflicts, test, then push.

## License and Credits

- License: AGPL-3.0 (see `LICENSE`)
- Original project and core credit: `sassanix/Warracker`
- This fork adds deployment and behavior changes listed above
