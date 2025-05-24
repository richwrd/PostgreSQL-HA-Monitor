#!/bin/bash

# Inicie o serviço do PostgreSQL
# Execute o script de inicialização do banco
/scripts/init_db.sh &

# Inicie o Patroni
su - postgres -c 'patroni /etc/patroni/patroni.yml'