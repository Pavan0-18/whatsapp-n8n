param(
  [switch]$Rebuild
)

Write-Host "Starting n8n WhatsApp-Drive Assistant..."
if ($Rebuild) {
  docker compose build --no-cache | cat
}
docker compose up -d | cat
Write-Host "n8n available at http://localhost:5678"

