FROM blacklabelops/java:openjre.8

ENV CROW_VERSION=1.0-SNAPSHOT \
    CROW_HOME=/opt/crow/ \
    CRONIUM_HOME=/opt/cronium \
    DOCKER_VERSION=18.03.0-ce

RUN apk add --update --no-cache --virtual .build-deps \
      curl && \
    mkdir -p ${CROW_HOME} && \
    mkdir -p ${CRONIUM_HOME} && \
    curl -fsSL https://26-112953069-gh.circle-artifacts.com/0/root/crow/application/target/crow-application-0.5-SNAPSHOT.jar -o ${CROW_HOME}/crow-application.jar && \
    curl -L -o /tmp/docker-${DOCKER_VERSION}.tgz https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && tar -xz -C /tmp -f /tmp/docker-${DOCKER_VERSION}.tgz && mv /tmp/docker/docker /usr/local/bin && \
    chmod +x /usr/local/bin/docker && \
    # Cleanup
    apk del .build-deps && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/* && rm -rf /var/log/*

COPY imagescripts ${CROW_HOME}

RUN cp ${CROW_HOME}/cronium.sh /usr/bin/cronium && \
    chmod +x /usr/bin/cronium

EXPOSE 8080
WORKDIR ${CRONIUM_HOME}
ENTRYPOINT ["/sbin/tini","--","/opt/crow/docker-entrypoint.sh"]
CMD ["cronium-server"]
