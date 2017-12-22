# Cronium - Dockerized Cron

Cron scheduler for container environments.

Why Cronium?

* Perfect for container environments, as it is easy configurable and customizable.
* You can specify the executing user.
* You can specify environment variables.
* Dedicated logging to console.
* Low profile cron scheduler.

# Make It Short

You can define an arbitrary amount of cron jobs. This images uses enumerated environment variables for multiple jobs.

Example Single Job:

~~~~
$ docker run -d --name cronium \
    -e "JOB1NAME=Job1" \
    -e "JOB1CRON=* * * * *" \
    -e "JOB1COMMAND=echo 'Hello World'" \
    blacklabelops/cronium
~~~~

> Note: All enumerations must start with 1!

Example Multiple Jobs:

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

## Global configuration

The global configuration consists of the following fields:

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
* `WORKING_DIRECTORY`: (Optional) The working directory. Default: Set by global configuration.
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
    -e "JOB1COMMAND=echo 'Hello World'" \
    -e "JOB1WORKING_DIRECTORY=/tmp" \
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

CMD ["cronium"]
~~~~

> Note: The base image is alpine and uses the apk package manager.

> All tools will be available for your cron commands.
