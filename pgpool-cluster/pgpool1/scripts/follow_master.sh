#!/bin/bash
# /etc/pgpool2/follow_master.sh (Versão 4.0)
# Script para sincronização automática entre Patroni e PgPool-II

# ==================== CONFIGURAÇÕES ====================
PGPOOL_USER="pgpool"                     # Usuário PCP
PGPOOL_PORT=9898                         # Porta PCP
LOG_FILE="/var/log/pgpool/follow_master.log"
LOCK_FILE="/tmp/pgpool_follow_master.lock"
REQUEST_TIMEOUT=3                         # Timeout para consultas (segundos)
MAX_RETRIES=3                            # Tentativas de conexão

# Nós Patroni (ajuste para seu ambiente)
PATRONI_NODES=("192.168.1.5:8008" "192.168.1.5:8009")

# Mapeamento nome Patroni -> ID PgPool (ajuste conforme seus nós)
declare -A NODE_MAP=(
    ["postgresql0"]=0
    ["postgresql1"]=1
)

# ==================== FUNÇÕES ====================

# Função para registrar logs com timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Função para verificar nó Patroni com retry
check_patroni_node() {
    local node=$1
    local url="http://${node}/cluster"
    local response=""
    
    for ((i=1; i<=MAX_RETRIES; i++)); do
        response=$(timeout $REQUEST_TIMEOUT curl -s "$url" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$response" ]; then
            echo "$response"
            return 0
        fi
        sleep 1
    done
    
    log "ERRO: Falha ao acessar nó $node após $MAX_RETRIES tentativas"
    echo ""
    return 1
}

# ==================== EXECUÇÃO PRINCIPAL ====================

# Configuração inicial
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Controle de concorrência
if [ -f "$LOCK_FILE" ]; then
    log "Processo já em execução. Saindo."
    exit 0
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

log "Iniciando sincronização PgPool2-Patroni"

# Variáveis para consenso
declare -A all_node_names
declare -A node_status
declare -A node_roles
consensus_leader=""
consensus_count=0
online_nodes=0

# 1. Coleta informações dos nós
for node in "${PATRONI_NODES[@]}"; do
    log "Consultando nó Patroni: $node"
    response=$(check_patroni_node "$node")
    
    if [ -n "$response" ]; then
        node_status["$node"]="online"
        ((online_nodes++))

        for row in $(echo "$response" | jq -r '.members[] | @base64'); do
            _jq() {
                echo "${row}" | base64 --decode | jq -r "${1}"
            }

            name=$(_jq '.name')
            role=$(_jq '.role')

            all_node_names["$name"]="$role"

            if [ "$role" == "leader" ]; then
                node_roles["$node"]="$name"

                if [ -z "$consensus_leader" ]; then
                    consensus_leader="$name"
                    consensus_count=1
                elif [ "$consensus_leader" == "$name" ]; then
                    ((consensus_count++))
                else
                    log "CONFLITO: $node reporta líder diferente ($name vs $consensus_leader)"
                fi
            fi
        done
    else
        node_status["$node"]="offline"
    fi
done


# 2. Lógica de decisão
if [ "$online_nodes" -eq 0 ]; then
    log "ERRO: Todos os nós Patroni offline"
    exit 1
elif [ "$online_nodes" -eq 1 ]; then
    consensus_leader=$(printf '%s\n' "${node_roles[@]}" | head -n1)
    log "AVISO: Modo degradado - Usando único nó online ($consensus_leader)"
else
    required_consensus=$(( (online_nodes / 2) + 1 ))
    if [ "$consensus_count" -lt "$required_consensus" ]; then
        log "ERRO: Sem consenso (necessário $required_consensus, obtido $consensus_count)"
        exit 1
    fi
fi

# 3. Mapeamento e ação
PRIMARY_ID="${NODE_MAP[$consensus_leader]}"
if [ -z "$PRIMARY_ID" ]; then
    log "ERRO: Nó $consensus_leader não mapeado (NODE_MAP: ${!NODE_MAP[@]})"
    exit 1
fi

# 4. Failback de nós "down" que já estão disponíveis
for node_name in "${!all_node_names[@]}"; do
    NODE_ID="${NODE_MAP[$node_name]}"

    if [ -z "$NODE_ID" ]; then
        log "AVISO: Nó $node_name não está mapeado em NODE_MAP"
        continue
    fi

    current_status=$(pcp_node_info -h localhost -U "$PGPOOL_USER" -p "$PGPOOL_PORT" -n "$NODE_ID" -w 2>/dev/null | awk '{print $5}')

    if [ "$current_status" != "up" ]; then
        log "Nó $node_name ($NODE_ID) marcado como DOWN no Pgpool. Tentando reanexar..."

        pcp_attach_node -h localhost -U "$PGPOOL_USER" -p "$PGPOOL_PORT" -n "$NODE_ID" -w >> "$LOG_FILE" 2>&1

        if [ $? -eq 0 ]; then
            log "Sucesso: Nó $node_name ($NODE_ID) reintegrado ao Pgpool"
        else
            log "ERRO: Falha ao reintegrar nó $node_name ($NODE_ID)"
        fi
    else
        log "Nó $node_name ($NODE_ID) já está UP no Pgpool"
    fi
done


log "Failback concluído"
exit 0