#!/bin/bash
# filepath: /postgresql-cluster/pgpool-cluster/pgpool0/scripts/generate_pool_passwd.sh

# Carregar variáveis do .env
set -a
source /etc/pgpool2/.env
set +a

# Verificar se as variáveis estão definidas
if [[ -z "$POSTGRES_USER" || -z "$POSTGRES_PASSWORD" ]]; then
  echo "Erro: POSTGRES_USER ou POSTGRES_PASSWORD não definido no .env"
  exit 1
fi

# Gerar hash MD5 da senha
PASSWORD_HASH="md5$(echo -n "${POSTGRES_PASSWORD}${POSTGRES_USER}" | md5sum | awk '{print $1}')"

# Criar o arquivo pool_passwd
echo "${POSTGRES_USER}:${PASSWORD_HASH}" > /etc/pgpool2/pool_passwd

# Definir permissões corretas
chown pgpool:pgpool /etc/pgpool2/pool_passwd
chmod 640 /etc/pgpool2/pool_passwd

echo "Arquivo pool_passwd gerado com sucesso."