#!/bin/bash


for (( i = 1; ; i++ ))
do
  VAR_JOB_ON_ERROR="JOB_ON_ERROR$i"
  VAR_JOB_NAME="JOB_NAME$i"
  VAR_JOB_COMMAND="JOB_COMMAND$i"
  VAR_JOB_TIME="JOB_TIME$i"
  VAR_JOB_NOTIFY_ERR="JOB_NOTIFY_ERR$i"
  VAR_JOB_NOTIFY_FAIL="JOB_NOTIFY_FAIL$i"

  if [ ! -n "${!VAR_JOB_NAME}" ]; then
    break
  fi

  migratedCron=$(echo "${!VAR_JOB_TIME}" | awk '{ $1=""; print}')

  echo $migratedCron

  export JOB${i}NAME=${!VAR_JOB_NAME}
  export JOB${i}CRON="$migratedCron"
  export JOB${i}COMMAND="${!VAR_JOB_COMMAND}"

  case "${!VAR_JOB_ON_ERROR}" in
    Continue)
      export JOB${i}ON_ERROR=continue
      ;;
    Stop)
      export JOB${i}ON_ERROR=stop
      ;;
    *)
      export JOB${i}ON_ERROR=continue
      ;;
  esac
done
