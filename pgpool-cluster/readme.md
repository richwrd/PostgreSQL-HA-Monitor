# Configuração de acesso ao pcp (UNIX)

## 1- criar uma senha md5

pg_md5 senha123

## 2- adicione o arquivo no pcp.conf

pgpool:37dcaa5d29e45b3386e7613fae2f574b

# Prefixo (utilize com: " -h localhost -p 9898 -U pgpool -W pgp001$#2025! " )

======================

pcp_common_options -- opções comuns usadas em comandos PCP
pcp_node_count -- exibe o número total de nós do banco de dados
pcp_node_info -- exibe as informações sobre o ID do nó fornecido
pcp_health_check_stats -- exibe dados de estatísticas de verificação de integridade no ID do nó fornecido
pcp_watchdog_info -- exibe o status do watchdog do Pgpool-II
pcp_proc_count -- exibe a lista de IDs de processos filhos do Pgpool-II
pcp_proc_info -- exibe as informações sobre o ID do processo filho Pgpool-II fornecido
pcp_pool_status — exibe os valores dos parâmetros conforme definidos em pgpool.conf
pcp_detach_node -- desvincula o nó fornecido do Pgpool-II. Conexões existentes com o Pgpool-II são forçadas a serem desconectadas.
pcp_attach_node — anexa o nó fornecido ao Pgpool-II.
pcp_promote_node -- promove o nó fornecido como novo principal para Pgpool-II
pcp_stop_pgpool -- encerra o processo Pgpool-II
pcp_reload_config -- recarregar arquivo de configuração pgpool-II
pcp_recovery_node -- anexa o nó de backend fornecido com recuperação

# Sufixo

-h localhost -p 9898 -U pgpool -W pgp001$#2025!

# STOP PROCESS ⚠️⚠️⚠️ se tiver instalado na maquina (etc/init.d/pgpool)

sudo pkill -9 pgpool

# -------------------------------------------------------------------
