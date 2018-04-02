#!/bin/bash

set -o errexit

[[ ${DEBUG} == true ]] && set -x

java -cp ${CROW_HOME}/crow-application.jar -Dloader.main=com.blacklabelops.crow.cli.CrowCli org.springframework.boot.loader.PropertiesLauncher "$@"
