FROM blacklabelops/java

ENV CROW_VERSION=1.0-SNAPSHOT \
    CROW_HOME=/opt/crow/

RUN apk add --update --no-cache --virtual .build-deps \
      curl && \
    mkdir -p ${CROW_HOME} && \
    curl -fsSL https://9-112953069-gh.circle-artifacts.com/0/root/crow/application/target/crow-application-1.0-SNAPSHOT.jar -o ${CROW_HOME}/crow-application.jar && \
    # Cleanup
    apk del .build-deps && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/* && rm -rf /var/log/*

COPY imagescripts ${CROW_HOME}
WORKDIR ${CROW_HOME}
ENTRYPOINT ["/sbin/tini","--","/opt/crow/docker-entrypoint.sh"]
CMD ["cronium"]
