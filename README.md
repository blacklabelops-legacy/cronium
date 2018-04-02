# Cronium - Dockerized Cron

[![Open Issues](https://img.shields.io/github/issues/blacklabelops/cronium.svg)](https://github.com/blacklabelops/cronium/issues) [![Stars on GitHub](https://img.shields.io/github/stars/blacklabelops/cronium.svg)](https://github.com/cblacklabelops/cronium/stargazers)
[![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/cronium.svg)](https://hub.docker.com/r/blacklabelops/cronium/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/cronium.svg)](https://hub.docker.com/r/blacklabelops/cronium/)

Cron scheduler for container environments.

Why Cronium?

* Commands are executed inside remote containers!
* Perfect for container environments, as it is easy configurable and customizable.
* You can specify the executing user.
* You can specify environment variables.
* Dedicated logging to console.
* Low profile cron scheduler.

## Supported Tags And Respective Dockerfile Links

| Bundle | Version | Tags  | Dockerfile | Readme | Example |
|--------|---------|-------|------------|--------|---------|
| Cronium  | latest | latest | [Dockerfile](https://github.com/blacklabelops/cronium/blob/master/Dockerfile) | [Readme](https://github.com/blacklabelops/cronium/blob/master/README.md) | blacklabelops/cronium:latest
| Cronium + Tools  | latest | tools | [Dockerfile](https://github.com/blacklabelops/cronium/blob/master/cronium-tools/Dockerfile) | | blacklabelops/cronium:tools |
| Cronium + Docker Tools | latest | docker | [Dockerfile](https://github.com/blacklabelops/cronium/blob/master/cronium-docker/Dockerfile) | [Readme](https://github.com/blacklabelops/cronium/blob/master/cronium-docker/README.md) | blacklabelops/cronium:docker |
| Cronium + AWS Cli | latest | aws | [Dockerfile](https://github.com/blacklabelops/cronium/blob/master/cronium-aws/Dockerfile) | [Readme](https://github.com/blacklabelops/cronium/blob/master/cronium-aws/README.md) | blacklabelops/cronium:aws |
| Cronium + GCE Cli | latest | gce | [Dockerfile](https://github.com/blacklabelops/cronium/blob/master/cronium-gcloud/Dockerfile) | [Readme](https://github.com/blacklabelops/cronium/blob/master/cronium-gcloud/README.md) | blacklabelops/cronium:gce |
| Cronium + All Above | latest | cloud | [Dockerfile](https://github.com/blacklabelops/cronium/blob/master/cronium-gcloud/Dockerfile) | [Readme](https://github.com/blacklabelops/cronium/blob/master/cronium-gcloud/README.md) | blacklabelops/cronium:cloud |

> AWS = Amazon Web Services, GCE = Google Cloud Engine

# Table Of Contents

* [Make It Short](#make-it-short)
* [Cron Configuration](#cron-configuration)
  * [Global Configuration](#global-configuration)
  * [Job Configuration](#job-configuration)
* [Changing The User](#changing-the-user)
* [Extending The Image](#extending-the-image)
* [Command Line Interface](#command-line-interface)
* [Jobber Migration](#jobber-migration)
* [References](#references)

# Make It Short

You can define an arbitrary amount of cron jobs running inside local or remote Docker containers.

This image uses enumerated environment variables for multiple jobs.

Example single job inside remote container:

~~~~
$ docker run -d --name cronium \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    -e "JOB1SHELL_COMMAND=docker exec CONTAINER_NAME /bin/bash -c" \
    blacklabelops/cronium
~~~~

> Note: Job will be executed inside bash shell inside container with name `CONTAINER_NAME`.

Example multiple jobs inside remote container:

~~~~
$ docker run -d --name cronium \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "CRONIUM_SHELL_COMMAND=docker exec CONTAINER_NAME /bin/bash -c" \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    -e "JOB2NAME=Job2" \
    -e "JOB2CRON=* * * * *" \
    -e "JOB2COMMAND=echo 'Hello Universe'" \
    blacklabelops/cronium
~~~~

> Note: All jobs will be executed inside bash shell inside container with name `CONTAINER_NAME`.

Example single job in local container:

~~~~
$ docker run -d --name cronium \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    blacklabelops/cronium
~~~~

> Note: All enumerations must start with 1!

Example nultiple jobs inside local container:

~~~~
$ docker run -d --name cronium \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    -e "JOB2NAME=Job2" \
    -e "JOB2CRON=* * * * *" \
    -e "JOB2COMMAND=echo 'Hello Universe'" \
    blacklabelops/cronium
~~~~

> Note: All enumerations must start with 1! You can only increment by 1!

# Cron Configuration

This image has a global configuration for all jobs and a job configuration for each job.

The global configuration sets values for all job but settings can be overriden by defining the same
configuration field inside a job configuration.

## Global Configuration

The global configuration consists of the following fields. The field's environment variables are all preceeded by `CRONIUM_`:

* `WORKING_DIRECTORY`: (Optional) The working directory for all cron jobs. Must be full path leading to an existing directory inside the container.
* `SHELL_COMMAND`: (Optional) The shell command for all cron jobs. Default: `/bin/bash -c`, all jobs are executed inside bash shell by default.
* `EXECUTION`: (Optional) The execution mode for all cron jobs. Possible values `parallel` or `sequential`. A single job will be either executes strictly sequential or multiple instances of the same job can run in parallel. Default is: `sequential`.
* `ON_ERROR`: (Optional) The error mode for all cron jobs. Possible values `stop` or `continue`. A single job will be either executed continuesly despite of errors or will not be scheduled anymore after an error occured. Default is: `continue`.

Setting a global configuration field:

All fields are configured as environment variables. The environment variable are preceeded by `CRONIUM_`:

Example:

~~~~
$ docker run -d --name cronium \
    -e "CRONIUM_WORKING_DIRECTORY=/tmp" \
    -e "CRONIUM_SHELL_COMMAND=/bin/bash -c" \
    -e "CRONIUM_EXECUTION=sequential" \
    -e "CRONIUM_ON_ERROR=continue" \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    blacklabelops/cronium
~~~~

> Jobs will be executed inside temp directory inside bash shell.

## Job Configuration

You can define an arbitrary amount of jobs. That's why jobs have to defined by enumerated environment variables starting from index 1, e.g. `JOB1`, `JOB2`, `JOB3` and so on.

Job settings are defined by configuration fields and the jobs can be defined using the following fields:

* `NAME`: (required) A unique job name, must be unique among all container's jobs.
* `CRON`: (required) The cron schedule. Specifics and syntax can be found here [Wikipedia - Cron](https://en.wikipedia.org/wiki/Cron)
* `COMMAND`: (required) Then command to be executed.
* `PRE_COMMAND`: (Optionel) This command to be executed before the actual command.
* `POST_COMMAND`: (Optionel) This command to be executed after the actual command.
* `WORKING_DIRECTORY`: (Optional) The working directory. Default: Set by global configuration.
* `TIMEOUT_MINUTES`: (Optional) Timeout for this job in minutes. Default: No timeout.
* `SHELL_COMMAND`: (Optional) The shell command. Default: Set by global configuration.
* `EXECUTION`: (Optional) The execution mode for this job. Default: Set by global configuration.
* `ON_ERROR`: (Optional) The error mode for this job. Default: Set by global configuration.

Setting a job configuration field:

All fields are configured as environment variables. The environment variable are preceeded by the enumerated jobs prefix, e.g. `JOB1`, `JOB2`, `JOB3`:

Example minimal job configuration:

~~~~
$ docker run -d --name cronium \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    blacklabelops/cronium
~~~~

> Job will print `Hello World` every minute.

Example full job configuration:

~~~~
$ docker run -d --name cronium \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1PRE_COMMAND=echo 'Hello World - Pre'" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    -e "JOB1POST_COMMAND=echo 'Hello World - Post'" \
    -e "JOB1WORKING_DIRECTORY=/tmp" \
    -e "JOB1TIMEOUT_MINUTES=1" \
    -e "JOB1SHELL_COMMAND=/bin/bash -c" \
    -e "JOB1EXECUTION=sequential" \
    -e "JOB1ON_ERROR=continue" \
    blacklabelops/cronium
~~~~

> Job will print `Hello World` every minute. Setting for working directory and shell will override global configuration.

# Changing The User

You can specify linux group id and user id for the scheduler. This is mandatory when you access files of other container and host files.

Example:

~~~~
$ docker run -d --name cronium \
    -e "CRONIUM_GID=1000" \
    -e "CRONIUM_UID=1000" \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    blacklabelops/cronium
~~~~

# Extending The Image

In most use cases I guess you will install your own scripts and tool set. You can extend this image by using the following Dockerfile contents:

~~~~
FROM blacklabelops/cronium
MAINTAINER Your Name <youremail@yourhost.com>

# install toolset via apk
RUN ...

CMD ["cronium-server"]
~~~~

> Note: The base image is alpine and uses the apk package manager.

> All tools will be available for your cron commands.

# Command Line Client

This image includes a command line interface (cli). The cli can be run against local or remote cronium server.

Supported Commands:

| Command | Description |
|---------|-------------|
| list | List all jobs. |
| version | Print client and server versions. |
| help | Print help. |

Configuration:

* `CRONIUM_BASE_URL`: The server's base url. Default: `http://localhost:8080`.

Usage:

~~~~
$ docker exec your_cronium_container cronium list
~~~~

> Lists all jobs in cronium container with name `your_cronium_container`.

Remote Usage:

~~~~
$ docker run --rm -e "CRONIUM_BASE_URL=http://your_cronium_container:8080" blacklabelops/cronium cronium list
~~~~

> Runs command against remote container with host name `your_cronium_container`.

Full Example:

1. Create Docker Network

~~~~
$ docker create network cronium
~~~~

2. Start Cronium

~~~~
$ docker run -d --name cronium \
    --network cronium
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    blacklabelops/cronium
~~~~

3. Remote List Cronium Jobs

~~~~
$ docker run --rm \
    --network cronium \
    -e "CRONIUM_BASE_URL=http://cronium:8080" \
    blacklabelops/cronium \
    cronium list
~~~~

# Jobber Migration

This image can be used with environment variables from `blacklabelops/jobber-cron`. Just run them without
your old environment variables, making migration from the other image easier.

Example:

~~~~
$ docker run -d \
	  --name cronium \
    -e "JOB_NAME1=TestEcho" \
    -e "JOB_COMMAND1=echo hello world" \
    -e "JOB_TIME1=1 * * * * *"
    blacklabelops/cronium
~~~~

Will be the same as running:

~~~~
$ docker run -d \
	  --name cronium \
    -e "JOB1NAME=TestEcho" \
    -e "JOB1COMMAND=echo hello world" \
    -e "JOB1CRON=* * * * *"
    blacklabelops/cronium
~~~~

Issues:

* Cronium does not have seconds specifier. So the last jobber cron number will be pruned.
* Jobbers `Backoff` will be interpreted as `continue`.

# References

* [Crow Cron Web Scheduler](https://github.com/blacklabelops/crow)
