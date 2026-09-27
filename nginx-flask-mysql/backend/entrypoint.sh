#!/bin/sh

mkdir -p /run/secrets

echo -n "$DB_PASSWORD" > /run/secrets/db-password

exec flask run
