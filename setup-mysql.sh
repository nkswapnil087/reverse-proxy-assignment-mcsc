#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$BASE/.env" ]; then set -a; . "$BASE/.env"; set +a; fi
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required. Copy .env.example to .env and set it.}"
MYSQL="$(command -v mysql || true)"
if [ -z "$MYSQL" ]; then
  echo "MySQL client is not installed. Install MySQL server/client first." >&2
  exit 1
fi
MYSQL_SOCKET_ARGS=()
if [ -n "${MYSQL_SOCKET:-}" ]; then MYSQL_SOCKET_ARGS=(--socket="$MYSQL_SOCKET"); fi
if ! "$MYSQL" "${MYSQL_SOCKET_ARGS[@]}" -u"${MYSQL_ADMIN_USER:-root}" -e 'SELECT 1' >/dev/null 2>&1; then
  echo "MySQL is not reachable. Start the local MySQL service, then run this script again." >&2
  exit 1
fi
"$MYSQL" "${MYSQL_SOCKET_ARGS[@]}" -u"${MYSQL_ADMIN_USER:-root}" <<SQL
CREATE DATABASE IF NOT EXISTS reverse_proxy_assignment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'assignment_user'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER 'assignment_user'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON reverse_proxy_assignment.* TO 'assignment_user'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL
"$MYSQL" "${MYSQL_SOCKET_ARGS[@]}" -u"${MYSQL_ADMIN_USER:-root}" < "$BASE/database/schema.sql"
echo "MySQL database reverse_proxy_assignment is ready on ${MYSQL_HOST:-127.0.0.1}:${MYSQL_PORT:-3306}"
