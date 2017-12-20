#!/bin/bash

set -o errexit

[[ ${DEBUG} == true ]] && set -x

function createCustomUser {
    local userid=$1
    local groupid=$2
    if [ -n "${groupid}" ]; then
        addgroup -g $groupid crow
    else
        addgroup crow
    fi
    adduser -G crow -s /bin/bash -u $userid -h /home/crow -S crow
    export HOME=/home/crow
}

function printUserInfo {
    local userid=$(id -u crow)
    local groupid=$(id -g crow)
    echo "Starting user with Group-Id: $groupid"
    echo "Starting user with User-Id: $userid"
}

function createEnvs {
    local configFile=$1
    local job=$2
    local VAR_TEST="${job}ENV1KEY"
    local i=1
    if [ -n "${!VAR_TEST}" ]; then
        cat >> $configFile <<_EOF_
    environments:
_EOF_
    fi
    for (( ; ; i++ ))
    do
        local VAR_ENV_KEY="${job}ENV${i}KEY"
        local VAR_ENV_VALUE="${job}ENV${i}VALUE"
        if [ ! -n "${!VAR_ENV_KEY}" ]; then
            break
        fi
        cat >> $configFile <<_EOF_
        ${!VAR_ENV_KEY}: ${!VAR_ENV_VALUE}
_EOF_
    done
}

function createJobs {
    local configFile=$1
    local i=1
    local VAR_JOB_NAME="JOB1NAME"
    if [ -n "${!VAR_JOB_NAME}" ]; then
        cat >> $configFile <<_EOF_
  jobs:
_EOF_
    fi
    for (( ; ; i++ ))
    do
        local VAR_JOB_NAME="JOB${i}NAME"
        local VAR_JOB_CRON="JOB${i}CRON"
        local VAR_JOB_COMMAND="JOB${i}COMMAND"
        if [ ! -n "${!VAR_JOB_NAME}" ]; then
            break
        fi
        cat >> $configFile <<_EOF_
    - name: ${!VAR_JOB_NAME}
      cron: '${!VAR_JOB_CRON}'
      command: ${!VAR_JOB_COMMAND}
_EOF_
        createEnvs $configFile JOB${i}
    done
}

function createConfig {
    touch application.yml
    cat > application.yml <<_EOF_
---

crow:
_EOF_
    createJobs application.yml
}

if [ ! -e "application.yml" ]; then
  createConfig
fi

if [ -n "${CROW_UID}" ]; then
  createCustomUser $CROW_UID $CROW_GID
  #chown crow:crow application.yml
fi

if [ "$1" = 'crow' ] || [ "${1:0:1}" = '-' ]; then
  if [ -n "${CROW_UID}" ]; then
      printUserInfo
      exec su-exec crow java -jar crow-application.jar "$@"
  else
    exec java -jar crow-application.jar "$@"
  fi
else
  if [ -n "${CROW_UID}" ]; then
    printUserInfo
    exec su-exec crow "$@"
  else
    exec "$@"
  fi
fi
