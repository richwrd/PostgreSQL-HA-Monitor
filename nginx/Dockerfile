FROM nginx:stable

# Cria o diretório de logs e garante as permissões
RUN mkdir -p /var/log/nginx && \
  touch /var/log/nginx/stream-access.log && \
  chown nginx:nginx /var/log/nginx/stream-access.log

# Copia o arquivo de configuração personalizado
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 5432

CMD ["nginx", "-g", "daemon off;"]