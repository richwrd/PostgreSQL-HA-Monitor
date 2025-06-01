#!/bin/bash

echo "Aguardando o PostgreSQL iniciar..."
until pg_isready -h localhost -p 5433 -U postgres; do
    sleep 10
done

echo "PostgreSQL está pronto. Executando o script SQL..."
psql -h localhost -p 5433 -U postgres -f /docker-entrypoint-initdb.d/create_role.sql
echo "Script SQL executado com sucesso!"