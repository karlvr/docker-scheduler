# Docker Scheduler

A cron-based scheduler service to run on a Docker Swarm to run tasks as Docker Swarm services.

Based on https://github.com/rayyanqcri/swarm-scheduler

## Overview

The scheduler container runs `cron`. You provide `crontab` files to run commands in the scheduler container,
or to start other services on your swarm to perform your tasks.

e.g.

```
30 8 * * * root <command>
41 9 * * * root run-service example
```

## Installation

You can declare the scheduler in a `docker-compose.yml` file. You must mount the `docker.sock` into the container, to enable the container to start services on the swarm (if you want to do that), and the container must run on a swarm manager in order to do that.

In this example we mount a host directory containing your `crontab` files to `/etc/cron.d`:

```yml
  scheduler:
    image: karlvr/scheduler
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /srv/cron.d:/etc/cron.d
    deploy:
      placement:
        constraints:
        - node.role == manager
```

Or you can create a derived image and install your own files in `/etc/cron.d` during the build process.

## crontab

If you place your `crontab` files in `/etc/cron.d` then they must be in the format above with the username.
You could also mount a file to `/etc/crontab`, which is in the same format.

## Swarm services

Large cron tasks are best run as swarm services, so they run on your swarm.

First create your services with the following deployment settings:

```yml
  example:
    ...
    deploy:
      replicas: 0
      restart_policy:
        condition: none
```

This is so they are declared, but not initially running, and so when they finish running they don't get restarted.

You could also set the `restart_policy` condition to `on-failure` so the job repeats if it fails.

Second, create a `crontab` file:

```
30 8 * * * root run-service example
```

The `run-service` script is part of the container, it simply uses the Docker cli to start the service on your swarm.
