#!/usr/bin/env bash
BASE="$(cd "$(dirname "$0")" && pwd)"
if command -v nginx >/dev/null 2>&1; then nginx -p "$BASE" -c "$BASE/nginx/nginx.conf" -s quit 2>/dev/null || true; fi
for name in backend frontend; do
  if [ -f "$BASE/run/$name.pid" ]; then kill "$(cat "$BASE/run/$name.pid")" 2>/dev/null || true; fi
done
echo "Stopped assignment services."
