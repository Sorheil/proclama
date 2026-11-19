#!/bin/sh
set -e
DB_HOST=$(echo "$DATABASE_URL" | sed -E 's#^[a-z]+://[^@]*@([^:/]+).*#\1#')
DB_PORT=$(echo "$DATABASE_URL" | sed -E 's#^.*@[^:/]+:([0-9]+)/.*#\1#')
until nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; do echo "attente de la base $DB_HOST:$DB_PORT"; sleep 1; done
exec "$@"
