#!/bin/sh

envsubst '${BACKEND_HOST}' < /etc/nginx/conf.d/default.conf > /tmp/default.conf

mv /tmp/default.conf /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
