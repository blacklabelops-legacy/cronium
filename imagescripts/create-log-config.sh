#!/bin/bash

function handleLogFilePattern() {
  local logPattern=${LOG4J_LOG_PATTERN:-'[%-5level] %d{yyyy-MM-dd HH:mm:ss} %c{1} - %msg%n'}
  export LOG4J_LOG_PATTERN=$logPattern
}

function createLogConfig() {
  handleLogFilePattern
  local sourceLogConfig=log4j2-spring.xml
  if [ -n "${LOG_FILE}" ]; then
    ( echo "cat <<EOF" ; cat ${CROW_HOME}/log4j2-spring-file.xml ; echo EOF ) | sh >> log4j.xml
  else
    ( echo "cat <<EOF" ; cat ${CROW_HOME}/log4j2-spring.xml ; echo EOF ) | sh >> log4j.xml
  fi
}
