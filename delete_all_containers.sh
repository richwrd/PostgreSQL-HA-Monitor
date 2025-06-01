#!/bin/bash

# Define o nome da stack
STACK_FILE="docker-compose.v5.yaml"

# Caminho do docker-compose
DOCKER_COMPOSE_CMD="sudo docker compose"

# Função para deletar a stack
delete_stack() {
  echo "Deletando a stack definida em $STACK_FILE..."
  $DOCKER_COMPOSE_CMD -f $STACK_FILE down
}


delete_stack