FROM alpine:3.22
ENV POCKET_ID_VERSION=v1.13.0

RUN apk add --no-cache rclone tini curl

WORKDIR /app
RUN mkdir -p /app/data && \
    mkdir -p /root/.config/rclone

RUN curl -sL -o pocket-id-linux-amd64 https://github.com/pocket-id/pocket-id/releases/download/${POCKET_ID_VERSION}/pocket-id-linux-amd64 && \
    chmod +x pocket-id-linux-amd64 && \
    mv pocket-id-linux-amd64 /usr/local/bin/pocket-id

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 1411
HEALTHCHECK --interval=1m --timeout=10s --start-period=20s \
  CMD rclone lsjson r2:${R2_BUCKET}${R2_PREFIX:+/${R2_PREFIX}} >/dev/null 2>&1 || exit 1
ENTRYPOINT ["/sbin/tini","--","/usr/local/bin/entrypoint.sh"]
