FROM docker.io/library/mariadb:10-focal

# Copy any custom database initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 3306
