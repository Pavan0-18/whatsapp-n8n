#!/usr/bin/env bash
set -euo pipefail

echo "Starting n8n WhatsApp-Drive Assistant..."
if [[ "${1:-}" == "--rebuild" ]]; then
  docker compose build --no-cache | cat
fi
docker compose up -d | cat
echo "n8n available at http://localhost:5678"

