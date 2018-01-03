# Dockerized Cronium Amazon Web Services (AWS)

Supports:

* Amazon Web Services (AWS)

# Make It Short!

In short, you can define periodic tasks your cloud environments.

Example:

~~~~
$ docker run -d --name cloudtask \
    -e "AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY" \
    -e "AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY" \
    -e "JOB1NAME=TestListingBuckets" \
    -e "JOB1COMMAND=aws s3 ls" \
    -e "JOB1TIME=* * * * *" \
    -e "JOB1ON_ERROR=stop" \
  blacklabelops/cronium:aws
~~~~

> Will list your buckets each minute.

# How It Works

This container is using blacklabelops/cronium for defining jobs. See this link for a comprehensive documentation: (blacklabelops/cronium)[https://github.com/blacklabelops/cronium]


# Amazon Web Services AWS

Required Environment Variables:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY

Optional Environment Variables:

* AWS_DEFAULT_REGION

Simply put your credentials inside the environment variables and call:

~~~~
$ docker run -d --name cloudtask \
    -e "AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY" \
    -e "AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY" \
    -e "AWS_DEFAULT_REGION=YOUR_REGION" \
    -e "JOB1NAME=TestListingBuckets" \
    -e "JOB1COMMAND=aws s3 ls" \
    -e "JOB1TIME=* * * * *" \
    -e "JOB1ON_ERROR=stop" \
  blacklabelops/cronium:aws
~~~~

> Will list your buckets each minute.

# References

* [Cronium](https://github.com/dshearer/cronium)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
