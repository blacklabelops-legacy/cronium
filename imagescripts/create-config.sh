#!/bin/bash

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

function createConfig {
    touch application.yml
    cat > application.yml <<_EOF_
---

_EOF_
}

function createPropertyFile {
    touch application.properties
    cat > application.properties <<_EOF_
spring.main.banner-mode=off
spring.config.location=${CROW_HOME}application.yml
spring.jackson.serialization.WRITE_DATES_AS_TIMESTAMPS=false
_EOF_
}
