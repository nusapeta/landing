FROM nginxinc/nginx-unprivileged:1.29-alpine

COPY site/ /usr/share/nginx/html/
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY deploy/headers.conf /etc/nginx/snippets/headers.conf

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
