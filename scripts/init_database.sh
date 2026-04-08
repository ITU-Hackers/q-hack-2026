#!/bin/bash
set -euo pipefail

EXTRA_DATABASES=(
  "dagster"
)

for db in "${EXTRA_DATABASES[@]}"; do
  echo "Creating database: $db"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-SQL
    SELECT 'CREATE DATABASE "$db"'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
SQL
  echo "Database '$db' created (or already exists)."
done
