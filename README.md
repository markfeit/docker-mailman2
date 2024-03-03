# Generic Docker Template


This directory contains a generic template for building Docker
containers.

## Setup Instructions

Edit the `Makefile` and adjust the variables in the top section as
directed.

If the `SUPERVISED` variable in the `Makefile` is undefined
(commented), edit `app/Dockerfile` to do anything
application-specific.

If the `SUPERVISED` variable in the `Makefile` is defined
(uncommented), add supervisord configuration files to
`supervisor/supervisor.d`.

Add any additional files containing Docker commands you want executed
in `Dockerfile.d`.  Each file should have a name beginning with a
two-digit number between `01` and `97` and a hyphen (e.g.,
`86-the-fish`).  The numbers `00`, `98` and `99` are used by the
template and should not be used.  The `Dockerfile` will be built from
these files sorted into numeric and then alphabetical order.

To build the container and run it interactively, run `make`.

To start a shell into a running container from another terminal, run
`make shell`.

To remove all build by-products run `make clean`.  Note that this does
not remove the built image from Docker.

When ready to commit a finished product to GitHub, run `make release`
to generate a `Dockerfile`.

Replace this file with everything below this line and fill in its
contents:

---

# Docker Container Template

## Docker

```
docker run markfeit/docker-mailman:latest
```

## Docker Compose

```
services:

  docker-template:
    image: markfeit/docker-mailman:latest
    # ...etc...
```

## Configuration

### The `/mailman` Volume

The container requires that the host provide a single shared directory
mounted on `/mailman` to hold all persistent data, logs and locks.

During boot, the container will initialize any missing directories
with defaults from the Mailman build.  This allows existing Mailman
installations to be migrated to this container

Generally, the structure of the directory is as follows:

```
/mailman/
|-- etc/
|   `-- mailman/
|       |-- mm_cfg.py
|       |-- sitelist.cfg
|       `-- templates/...
`-- var/
    |-- lib/
    |   `-- mailman/
    |       |-- archives/
    |       |   |-- private/
    |       |   `-- public/
    |       |-- data/
    |       |-- lists/
    |       `-- spam/
    |-- run/
    |   `-- mailman/
    `-- spool/
        `-- mailman/
```


## Notes

Some inspiration taken from:

 * https://github.com/macropin/docker-mailman
