FROM blacklabelops/java:openjre.8

ENV CROW_VERSION=1.0-SNAPSHOT \
    CROW_HOME=/opt/crow/ \
    CRONIUM_HOME=/opt/cronium

RUN apk add --update --no-cache --virtual .build-deps \
      curl && \
    mkdir -p ${CROW_HOME} && \
    mkdir -p ${CRONIUM_HOME} && \
    curl -fsSL https://14-112953069-gh.circle-artifacts.com/0/root/crow/application/target/crow-application-0.5-SNAPSHOT.jar -o ${CROW_HOME}/crow-application.jar && \
    # Cleanup
    apk del .build-deps && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/* && rm -rf /var/log/*

COPY imagescripts ${CROW_HOME}
WORKDIR ${CRONIUM_HOME}
ENTRYPOINT ["/sbin/tini","--","/opt/crow/docker-entrypoint.sh"]
CMD ["cronium"]
