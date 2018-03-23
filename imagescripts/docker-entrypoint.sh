#!/bin/bash

set -o errexit

[[ ${DEBUG} == true ]] && set -x

function pipeEnvironmentVariables() {
  local environmentfile="/etc/profile.d/cronium.sh"
  cat > ${environmentfile} <<_EOF_
  #!/bin/sh
_EOF_
  sh -c export >> ${environmentfile}
  sed -i.bak '/^export [a-zA-Z0-9_]*:/d' ${environmentfile}
}

function createCustomUser {
    local userid=$1
    local groupid=$2
    if [ -n "${groupid}" ]; then
        addgroup -g $groupid cronium
    else
        addgroup cronium
    fi
    adduser -G cronium -s /bin/bash -u $userid -h /home/cronium -S cronium
    export HOME=/home/cronium
}

function printUserInfo {
    local userid=$(id -u cronium)
    local groupid=$(id -g cronium)
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
        local VAR_JOB_PRE_COMMAND="JOB${i}PRE_COMMAND"
        local VAR_JOB_POST_COMMAND="JOB${i}POST_COMMAND"
        local VAR_JOB_SHELLCOMMAND="JOB${i}SHELLCOMMAND"
        local VAR_JOB_WORKDIR="JOB${i}WORKDIR"
        local VAR_JOB_ON_ERROR="JOB${i}ON_ERROR"
        local VAR_JOB_EXECUTION="JOB${i}EXECUTION"
        local VAR_JOB_TIMEOUT_MINUTES="JOB${i}TIMEOUT_MINUTES"

        if [ ! -n "${!VAR_JOB_NAME}" ]; then
            break
        fi
        cat >> $configFile <<_EOF_
    - name: ${!VAR_JOB_NAME}
      cron: '${!VAR_JOB_CRON}'
      command: ${!VAR_JOB_COMMAND}
_EOF_

      local jobWorkingDir=
      if [ -n "${!VAR_JOB_WORKDIR}" ]; then
        jobWorkingDir=${!VAR_JOB_WORKDIR}
      elif [ -n "${CRONIUM_WORKING_DIRECTORY}" ]; then
        jobWorkingDir=${CRONIUM_WORKING_DIRECTORY}
      fi

      if [ -n "${jobWorkingDir}" ]; then
        cat >> $configFile <<_EOF_
      workingDirectory: ${jobWorkingDir}
_EOF_
      fi

      local jobShellCommand=
      if [ -n "${!VAR_JOB_SHELLCOMMAND}" ]; then
        jobShellCommand=${!VAR_JOB_SHELLCOMMAND}
      elif [ -n "${CRONIUM_WORKING_DIRECTORY}" ]; then
        jobShellCommand=${CRONIUM_WORKING_DIRECTORY}
      else
        jobShellCommand="/bin/bash -c"
      fi

      if [ -n "${jobShellCommand}" ]; then
        cat >> $configFile <<_EOF_
      shellCommand: ${jobShellCommand}
_EOF_
      fi

      local jobOnError=
      if [ -n "${!VAR_JOB_ON_ERROR}" ]; then
        jobOnError=${!VAR_JOB_ON_ERROR}
      elif [ -n "${CRONIUM_ON_ERROR}" ]; then
        jobOnError=${CRONIUM_ON_ERROR}
      else
        jobOnError="continue"
      fi

      if [ -n "${jobOnError}" ]; then
        cat >> $configFile <<_EOF_
      errorMode: ${jobOnError}
_EOF_
      fi

      local jobExecution=
      if [ -n "${!VAR_JOB_EXECUTION}" ]; then
        jobExecution=${!VAR_JOB_EXECUTION}
      elif [ -n "${CRONIUM_EXECUTION}" ]; then
        jobExecution=${CRONIUM_EXECUTION}
      else
        jobExecution="sequential"
      fi

      if [ -n "${jobExecution}" ]; then
        cat >> $configFile <<_EOF_
      execution: ${jobExecution}
_EOF_
      fi

      local preCommand=
      if [ -n "${!VAR_JOB_PRE_COMMAND}" ]; then
        preCommand=${!VAR_JOB_PRE_COMMAND}
      fi

      if [ -n "${preCommand}" ]; then
        cat >> $configFile <<_EOF_
      preCommand: ${preCommand}
_EOF_
      fi

      local postCommand=
      if [ -n "${!VAR_JOB_POST_COMMAND}" ]; then
        postCommand=${!VAR_JOB_POST_COMMAND}
      fi

      if [ -n "${postCommand}" ]; then
        cat >> $configFile <<_EOF_
      postCommand: ${postCommand}
_EOF_
      fi

      local timeoutMinutes=
      if [ -n "${!VAR_JOB_TIMEOUT_MINUTES}" ]; then
        timeoutMinutes=${!VAR_JOB_TIMEOUT_MINUTES}
      fi

      if [ -n "${timeoutMinutes}" ]; then
        cat >> $configFile <<_EOF_
      timeOutMinutes: ${timeoutMinutes}
_EOF_
      fi

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

if [ -n "${CRONIUM_UID}" ]; then
  createCustomUser $CRONIUM_UID $CRONIUM_GID
  #chown crow:crow application.yml
fi

if [ "${DEBUG}" = 'true' ]; then
  cat application.yml
fi

source $CROW_HOME/import-gpg.sh

if [ "$1" = 'cronium' ] || [ "${1:0:1}" = '-' ]; then
  pipeEnvironmentVariables
  if [ -n "${CROW_UID}" ]; then
      printUserInfo
      exec su-exec cronium java -jar ${CROW_HOME}/crow-application.jar "$@"
  else
    exec java -jar ${CROW_HOME}/crow-application.jar "$@"
  fi
else
  if [ -n "${CROW_UID}" ]; then
    printUserInfo
    exec su-exec cronium "$@"
  else
    exec "$@"
  fi
fi
