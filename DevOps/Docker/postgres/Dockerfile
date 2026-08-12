FROM postgres:16-alpine

COPY apps/backcore/db/init.sql /docker-entrypoint-initdb.d/01-init.sql
COPY apps/backcore/db/data.sql /docker-entrypoint-initdb.d/02-data.sql

EXPOSE 5432
