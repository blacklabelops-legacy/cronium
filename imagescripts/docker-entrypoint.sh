#!/bin/bash

set -o errexit

[[ ${DEBUG} == true ]] && set -x

source ${CROW_HOME}/create-config.sh

source ${CROW_HOME}/jobber-migration.sh

source $CROW_HOME/import-gpg.sh

if [ ! -e "application.yml" ]; then
  createConfig
fi

if [ -n "${CRONIUM_UID}" ]; then
  createCustomUser $CRONIUM_UID $CRONIUM_GID
fi

if [ "${DEBUG}" = 'true' ]; then
  cat application.yml
fi

log4j_config=${CROW_HOME}/log4j2-spring.xml
if [ -n "${LOG4J_CONFIG}" ]; then
  log4j_config=${LOG4J_CONFIG}
fi

importKeys

if [ "$1" = 'cronium' ] || [ "${1:0:1}" = '-' ]; then
  migrateJobberEnvs
  pipeEnvironmentVariables
  if [ -n "${CROW_UID}" ]; then
      printUserInfo
      exec su-exec cronium java -Dlogging.config=${log4j_config} -jar ${CROW_HOME}/crow-application.jar "$@"
  else
    exec java -Dlogging.config=${log4j_config} -jar ${CROW_HOME}/crow-application.jar "$@"
  fi
else
  if [ -n "${CROW_UID}" ]; then
    printUserInfo
    exec su-exec cronium "$@"
  else
    exec "$@"
  fi
fi
