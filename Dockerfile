FROM alpine:3.5

RUN apk update && \
    apk add squid bash && \
    rm -rf /var/cache/apk/*

ENV HTTP_PROXY http://127.0.0.1:9090
ENV NO_PROXY_NETWORKS 10.0.0.0/8 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4
EXPOSE 3128

VOLUME /var/log/squid

ADD run.sh /run.sh
CMD ["/bin/bash", "/run.sh"]
