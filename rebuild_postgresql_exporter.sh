#!/bin/bash

# Define o nome da stack
STACK_FILE="docker-compose.v5.yaml"

# Caminho do docker-compose
DOCKER_COMPOSE_CMD="sudo docker compose -f $STACK_FILE"

rebuild_exporter() {
  local container_name=$1
  echo "Parando e removendo o container $container_name..."
  $DOCKER_COMPOSE_CMD stop $container_name
  $DOCKER_COMPOSE_CMD rm -f $container_name
  if [ $? -eq 0 ]; then
    echo "Container $container_name removido com sucesso. Buildando novamente..."
    $DOCKER_COMPOSE_CMD build $container_name
    if [ $? -eq 0 ]; then
      echo "Container $container_name buildado com sucesso. Iniciando..."
      $DOCKER_COMPOSE_CMD up -d $container_name
      if [ $? -eq 0 ]; then
        echo "Container $container_name iniciado com sucesso."
      else
        echo "Erro ao iniciar o container $container_name."
      fi
    else
      echo "Erro ao buildar o container $container_name."
    fi
  else
    echo "Erro ao remover o container $container_name."
  fi
}

# Executa a função para os dois containers
rebuild_exporter "postgresql1-exporter"
rebuild_exporter "postgresql0-exporter"