#!/usr/bin/env bash
set -euo pipefail
if command -v nginx >/dev/null 2>&1; then
  nginx -v 2>&1
  exit 0
fi
echo "NGINX is not installed. Install it with:"
echo "  sudo apt-get update && sudo apt-get install -y nginx"
exit 1
