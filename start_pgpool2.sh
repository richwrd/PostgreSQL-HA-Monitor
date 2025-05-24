#!/bin/bash

# Define o nome da stack
STACK_FILE="docker-compose.v3.yml"

# Caminho do docker-compose
DOCKER_COMPOSE_CMD="sudo docker compose -f $STACK_FILE"

rebuild_pgpool() {
  echo "Parando e removendo os containers do Pgpool..."
  $DOCKER_COMPOSE_CMD stop pgpool0 pgpool1
  $DOCKER_COMPOSE_CMD rm -f pgpool0 pgpool1
  if [ $? -eq 0 ]; then
    echo "Containers do Pgpool removidos com sucesso. Buildando novamente..."
    $DOCKER_COMPOSE_CMD build pgpool0 pgpool1
    if [ $? -eq 0 ]; then
      echo "Containers do Pgpool buildados com sucesso. Iniciando..."
      $DOCKER_COMPOSE_CMD up -d pgpool0 pgpool1
      if [ $? -eq 0 ]; then
        echo "Containers do Pgpool iniciados com sucesso."
      else
        echo "Erro ao iniciar os containers do Pgpool."
      fi
    else
      echo "Erro ao buildar os containers do Pgpool."
    fi
  else
    echo "Erro ao remover os containers do Pgpool."
  fi
}

# Executa a função
rebuild_pgpool