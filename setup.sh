#!/bin/sh
# Setup script for Stackoverflow Phoenix project
# Usage: ./setup.sh
set -e

# Find docker compose command
if command -v docker compose > /dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose > /dev/null 2>&1; then
  DC="docker-compose"
else
  echo "[ERROR] Neither 'docker compose' nor 'docker-compose' found. Please install Docker Desktop: https://www.docker.com/products/docker-desktop/"
  exit 1
fi

echo "[INFO] Starting PostgreSQL via Docker Compose..."
$DC up -d db

echo "[INFO] Waiting for Postgres to be ready..."
RETRIES=20
until docker exec $($DC ps -q db) pg_isready -U postgres > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "  Waiting for database... ($RETRIES retries left)"
  sleep 1
  RETRIES=$((RETRIES-1))
done
if [ $RETRIES -eq 0 ]; then
  echo "[ERROR] Postgres did not become ready in time."
  exit 1
fi

echo "[INFO] Running mix setup (deps, db, assets, seed)..."
mix setup

echo "[INFO] Setup complete!"
echo "  Seeded user: johndoe@example.com / password"
echo "  To start the server: mix phx.server" 