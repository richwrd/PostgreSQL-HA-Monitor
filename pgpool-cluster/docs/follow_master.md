# 🔁 follow_master.sh — Failback Automático do Pgpool-II com Patroni

Este script garante que o **Pgpool-II** esteja sempre sincronizado com o nó **primário (líder)** do cluster PostgreSQL gerenciado pelo **Patroni**, realizando failback automático para reintegrar nós que voltaram ao ar.

---

## ⚙️ Como Funciona?

- Consulta a **API REST** do Patroni (`/cluster`) de todos os nós configurados.
- Identifica o **nó líder atual** (role `= leader`).
- Mapeia o nome do líder ao **ID correspondente no Pgpool-II**.
- Reanexa automaticamente ao Pgpool-II os nós que estavam marcados como `down`, caso estejam novamente disponíveis.

---

## 📦 Recursos e Comportamento

- ✅ **Consenso entre nós Patroni**: o líder só é aceito se for reportado por maioria dos nós online.
- ⚠️ **Modo degradado**: se apenas 1 nó responder, ele é aceito como líder para manter o cluster operando.
- 🔐 **Modo seguro**: se nenhum nó Patroni estiver disponível, o script **não realiza alterações** e registra erro nos logs.
- 🔁 **Failback automático**: reintegra nós `down` ao Pgpool assim que são detectados como disponíveis.
- 🔒 **Controle de concorrência**: evita múltiplas execuções simultâneas com arquivo de lock (`/tmp`).

---

## ✅ Vantagens

- 🔄 Failback automático e sem intervenção manual.
- 👑 Sincronização baseada exclusivamente na autoridade do Patroni.
- ⚙️ Compatível com ambientes de 2 nós.
- 🧰 Logs detalhados para fácil troubleshooting.
- 🔧 Simples de configurar e manter.

---

## ⚠️ Limitações

- ❌ Em falha total de todos os nós Patroni, o script não executa alterações (por segurança).
- 🔁 O follow_master_command só é executado automaticamente pelo Pgpool-II durante failovers — para execução periódica, recomenda-se agendamento via cron.

---

## 🛠️ Exemplo de Ambiente

- Cluster PostgreSQL: gerenciado por Patroni com 2 nós
- Pgpool-II: gerenciando a conexão e failover entre os nós
- Watchdog: usado para alta disponibilidade do próprio Pgpool-II
- Failover automático: gerenciado pelo Patroni
- Failback automático: realizado por este script via pcp_attach_node

---

Feito com ❤️ por Richard.
