# Cronium - Dockerized Cron

This is still work in progress!

Crow is a cron web scheduler for container environments.

Why Cronium?

* Perfect for container environments, as it is easy configurable and customizable.
* You can specify the executing user.
* You can specify environment variables.
* Dedicated logging to console.
* Low profile cron scheduler.

# Defining Jobs

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

# Changing The User

You can specify linux group id and user id for the scheduler. This is mandatory when you access files of other container and host files.

Example:

~~~~
$ docker run -d --name cronium \
    -e "CROW_GID=1000" \
    -e "CROW_UID=1000" \
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
