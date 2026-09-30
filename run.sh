#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$BASE/.env" ]; then set -a; . "$BASE/.env"; set +a; fi
mkdir -p "$BASE/logs" "$BASE/run" "$BASE/run/client_body" "$BASE/run/proxy_temp" "$BASE/run/fastcgi_temp" "$BASE/run/uwsgi_temp" "$BASE/run/scgi_temp"

"$BASE/setup-mysql.sh"

if ! command -v nginx >/dev/null 2>&1; then
  echo "NGINX is not installed. Run ./setup-nginx.sh first." >&2
  exit 1
fi
setsid nohup python3 "$BASE/backend/server.py" >"$BASE/logs/backend.log" 2>&1 </dev/null & echo $! > "$BASE/run/backend.pid"
setsid nohup python3 "$BASE/frontend/server.py" >"$BASE/logs/frontend.log" 2>&1 </dev/null & echo $! > "$BASE/run/frontend.pid"
sleep 0.3
nginx -p "$BASE" -c "$BASE/nginx/nginx.conf"
echo "Running: frontend 3000, backend 5000, NGINX proxy 8080"
