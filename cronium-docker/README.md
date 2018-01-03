# Dockerized Cronium Docker

Supports:

* Docker
* Docker-Compose
* Docker-Machine

# Make It Short!

In short, you can define periodic tasks for your docker host.

Example:

~~~~
$ docker run -d --name cloudtask \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "JOB1NAME=TestEcho" \
    -e "JOB1COMMAND=docker ps" \
    -e 'JOB1CRON=* * * * *' \
    -e "JOB1ON_ERROR=stop" \
    blacklabelops/cronium:docker
~~~~

> Will list your docker processes each minute.

# How It Works

This container is using blacklabelops/cronium for defining jobs. See this link for a comprehensive documentation: (blacklabelops/cronium)[https://github.com/blacklabelops/cronium]

# Docker

You will need a docker demon in order to enable docker cli or docker-compose. Simply mount your local docker demon or start one inside a linked container!

Example mounting local docker demon:

~~~~
$ docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "DOCKER_HOST=" \
    -e "JOB1NAME=TestEcho" \
    -e "JOB1COMMAND=docker images" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1ON_ERROR=continue" \
    blacklabelops/cronium:docker
~~~~

> Will list local image list every minute.

## Docker Login

The container can be started and login in a remote repository. The default is the dockerhub registry.

With the environment variables:

* DOCKER_REGISTRY_USER: Your account username for the registry. (mandatory)
* DOCKER_REGISTRY_EMAIL: Your account email for the registry. (mandatory)
* DOCKER_REGISTRY_PASSWORD: Your account password for the registry. (mandatory)

Example:

~~~~
$ docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "DOCKER_REGISTRY_USER=**Your_Account_Username**" \
    -e "DOCKER_REGISTRY_EMAIL=**Your_Account_Email**" \
    -e "DOCKER_REGISTRY_PASSWORD=**Your_Account_Password**" \
    -e "JOB1NAME=TestEcho" \
    -e "JOB1COMMAND=docker push blacklabelops/centos" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1ON_ERROR=continue" \
    blacklabelops/cronium:docker
~~~~

> Will push the container to dockerhub every minute.

## Changing the Docker registry

The default for this container is dockerhub.io. If you want to use another remote repository, e.g. quay.io then Your_Account_Email can specify the repository with the environment variable DOCKER_REGISTRY.

Example:

~~~~
$ docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "DOCKER_REGISTRY=quay.io" \
    -e "DOCKER_REGISTRY_USER=**Your_Account_Username**" \
    -e "DOCKER_REGISTRY_EMAIL=**Your_Account_Email**" \
    -e "DOCKER_REGISTRY_PASSWORD=**Your_Account_Password**" \
    -e "JOB1NAME=TestEcho" \
    -e "JOB1COMMAND=docker push quay.io/blacklabelops/centos" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1ON_ERROR=Backoff" \
    blacklabelops/cronium:docker
~~~~

> Will push the container to quay.io every minute.

# References

* [Cronium](https://github.com/blacklabelops/cronium)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
