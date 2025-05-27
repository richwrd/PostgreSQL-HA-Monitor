#!/bin/bash

# Define o nome da stack
STACK_FILE="docker-compose.v5.yaml"

# Caminho do docker-compose
DOCKER_COMPOSE_CMD="sudo docker compose"

# Lista de portas utilizadas no docker-compose
PORTS=(
  "2379"  # etcd
  "5433"  # PostgreSQL (postgresql0)
  "8008"  # Patroni API (postgresql0)
  "5434"  # PostgreSQL (postgresql1)
  "8009"  # Patroni API (postgresql1)
  "5430"  # Pgpool (pgpool0)
  "9000"  # Watchdog (pgpool0)
  "5431"  # Pgpool (pgpool1)
  "9001"  # Watchdog (pgpool1)
  "9188"  # Pgpool (postgresql0-exporter)
  "9187"  # Pgpool (postgresql0-exporter)
  "5432"  # PostgreSQL CENTRAL (NGINX)
)

# Função para verificar se as portas estão em uso
check_ports() {
  echo "Verificando se as portas definidas no docker-compose estão em uso..."
  for PORT in "${PORTS[@]}"; do
    if lsof -i:"$PORT" > /dev/null 2>&1; then
      echo "A porta $PORT está em uso."
      while true; do
        echo -n "Deseja finalizar o processo que está utilizando a porta $PORT? (s/n): "
        read -r RESPONSE
        case "$RESPONSE" in
          [sS])
            PID=$(lsof -t -i:"$PORT")
            echo "Finalizando o processo $PID que está utilizando a porta $PORT..."
            kill -9 "$PID"
            if [ $? -eq 0 ]; then
              echo "Processo $PID finalizado com sucesso."
              # Verifica novamente se a porta ainda está em uso
              if lsof -i:"$PORT" > /dev/null 2>&1; then
                echo "Erro: A porta $PORT ainda está em uso após tentar finalizar o processo."
                exit 1
              else
                echo "A porta $PORT foi liberada com sucesso."
              fi
            else
              echo "Erro ao finalizar o processo $PID."
              exit 1
            fi
            break
            ;;
          [nN])
            echo "Porta $PORT continuará em uso. O script será encerrado."
            exit 1
            ;;
          *)
            echo "Resposta inválida. Por favor, responda com 's' ou 'n'."
            ;;
        esac
      done
    else
      echo "A porta $PORT não está em uso."
    fi
  done
}

# Função para verificar e carregar o módulo softdog
initialize_watchdog() {
  echo "Verificando o módulo softdog..."
  if ! lsmod | grep -q softdog; then
    echo "Carregando o módulo softdog..."
    sudo modprobe softdog
    if [ $? -eq 0 ]; then
      echo "Módulo softdog carregado com sucesso."
    else
      echo "Erro ao carregar o módulo softdog. Verifique as permissões."
      exit 1
    fi
  else
    echo "Módulo softdog já está carregado."
  fi
}

# Função para criar a pasta watchdog
create_watchdog_folder() {
  WATCHDOG_DIR="/dev/watchdog"
  echo "Verificando o dispositivo watchdog..."
  
  # Verifica se já existe como arquivo ou dispositivo
  if [ -e "$WATCHDOG_DIR" ]; then
    echo "O dispositivo watchdog já existe."
    # Verifica permissões do dispositivo existente
    PERMS=$(stat -c "%a" "$WATCHDOG_DIR")
    if [ "$PERMS" != "777" ]; then
      echo "Alterando permissões do dispositivo watchdog para 777..."
      sudo chmod 777 "$WATCHDOG_DIR"
      if [ $? -eq 0 ]; then
        echo "Permissões do dispositivo watchdog alteradas para 777 com sucesso."
      else
        echo "Erro ao alterar permissões do dispositivo watchdog."
        exit 1
      fi
    else
      echo "Dispositivo watchdog já possui as permissões corretas."
    fi
  else
    # Se não existe, tenta criar como dispositivo
    echo "Dispositivo watchdog não encontrado."
    echo "O dispositivo watchdog deve ser criado pelo módulo do kernel."
    exit 1
  fi
}


# Função para deletar a stack
delete_stack() {
  echo "Deletando a stack definida em $STACK_FILE..."
  $DOCKER_COMPOSE_CMD -f $STACK_FILE down
}

# Função para subir a stack novamente
start_stack() {
  echo "Subindo a stack definida em $STACK_FILE..."
  $DOCKER_COMPOSE_CMD -f $STACK_FILE up -d
}

# Executa as funções
initialize_watchdog
create_watchdog_folder
delete_stack
check_ports
start_stack

echo "Processo concluído."