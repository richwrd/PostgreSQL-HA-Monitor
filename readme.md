1- starte o wsl, rode o olama com o comando

```bash
OLLAMA_HOST=0.0.0.0:11434 ollama serve;
```

2-acesse pelo ip do wsl:

```bash
ip addr show eth0 | grep 'inet '
```

- inet 172.19.225.15/20

docker-compose -f docker-compose.v1.yml --env-file ./.env up

modifique o ip em:

pgpool
postgresql1
postgresql2
