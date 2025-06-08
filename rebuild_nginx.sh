#!/bin/bash

# Define o nome da stack
STACK_FILE="docker-compose.v7.yaml"

# Caminho do docker-compose
DOCKER_COMPOSE_CMD="sudo docker compose -f $STACK_FILE"

rebuild_nginx() {
  echo "Parando e removendo o container do Nginx..."
  $DOCKER_COMPOSE_CMD stop nginx
  $DOCKER_COMPOSE_CMD rm -f nginx
  if [ $? -eq 0 ]; then
    echo "Container do Nginx removido com sucesso. Buildando novamente..."
    $DOCKER_COMPOSE_CMD build nginx
    if [ $? -eq 0 ]; then
      echo "Container do Nginx buildado com sucesso. Iniciando..."
      $DOCKER_COMPOSE_CMD up -d nginx
      if [ $? -eq 0 ]; then
        echo "Container do Nginx iniciado com sucesso."
      else
        echo "Erro ao iniciar o container do Nginx."
      fi
    else
      echo "Erro ao buildar o container do Nginx."
    fi
  else
    echo "Erro ao remover o container do Nginx."
  fi
}

# Executa a função
rebuild_nginx