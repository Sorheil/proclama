#!/bin/sh
set -e

HOST=$(echo "$DATABASE_URL" | sed -E 's#^[a-z]+://[^@]*@([^:/]+).*#\1#')
DB_PORT=$(echo "$DATABASE_URL" | sed -E 's#^.*@[^:/]+:([0-9]+)/.*#\1#')

until nc -z "$HOST" "$DB_PORT" 2>/dev/null; do
    echo "attente de la base $HOST:$DB_PORT"
    sleep 1
done

exec "$@"
