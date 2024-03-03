# Mailman 2 Container

This container runs [GNU Mailman](https://list.org/) 2.x with all
persistent data in a single host directory.

This container is based on Oracle Linux 8, which is the last-surviving
distribution which is stil supported by the distributor.  **Regular
support ends on July 1, 2029 and extended support ends July 1, 2031.
Use of this container is not recommended or supported after those
dates.**

Throughout this document, the directory on the where all
mailman-related files are placed will be referred to as
`/system/mailman`.

## Build and Test

To build the container's `Dockerfile`, run `make`.

The `run` target will build and run the container in the foreground
and the `shell` target will start an interactive shell on it.

This container will be available on the GitHub Container Repository in
the near future.


## Docker

**NOTE:** It is recommended (but not required) that the container's
   name and hostname be the same as the FQDN of the mailman web
   server's URL.  See below.  <!-- TODO: Link. -->

```
docker run \
    --name=mailman.example.com \
    --hostname=mailman.example.com \
    --volume=/system/mailman:/mailman \
    --publish=9999:80 \
    markfeit/mailman2
```

## Docker Compose

```
services:

  mailman2:
    image: markfeit/mailman2
    name: mailman.example.com
    hostname: mailman.example.com
    ports:
      - '9999:80'
    volumes:
      - /system/mailman:/mailman
```

## Container Configuration

### The `/mailman` Volume

The container requires that the host provide a single shared directory
mounted on its `/mailman` to hold all persistent data, logs and locks.
The arrangement of this directory generally mirrors that of a system
running Mailman:

```
/mailman/
|-- bin/   (See note below)
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

During boot, the container will initialize any missing directories
with the defaults provided by the container's installed Mailman.  This
allows existing Mailman 2.x installations to be migrated to this
container.

The `bin` directory will be configured by the container with a program
used on the host to send incoming mail into Mailman.  See _Host
Configuration_, below.  <!-- TODO: Link. -->


### Mailman Configuration

Generally, the default configuration (`etc/mailman/mm_cf.py`) should
be used with minor modifications:

```
# Set this to the domain where emails should be sent, used in the
# contact information on the listinfo page.
DEFAULT_EMAIL_HOST = 'example.com'

# Show all public lists regardless of whether or not the host names
# match.
VIRTUAL_HOST_OVERVIEW = Off

# How and where to send outbound emails because the container does not
# run a MTA of its own.
DELIVERY_MODULE = 'SMTPDirect'
SMTPHOST = 'mailout.example.com'
```

## Host Configuration

The following will need to be configured on the host:

### Web Server

The host's web server must be configured as a proxy to send requests
into the container's port 80 via another port (e.g., with `--publish
9999:80`).

Note that the container **does not provide HTTPS**.

A sample configuration for Apache is provided in
`scripts/apache-host.conf`.


### Mail Server

#### Postifx and Sendmail

```
listname:             "|/system/mailman/bin/mailman post listname"
listname-admin:       "|/system/mailman/bin/mailman admin listname"
listname-bounces:     "|/system/mailman/bin/mailman bounces listname"
listname-confirm:     "|/system/mailman/bin/mailman confirm listname"
listname-join:        "|/system/mailman/bin/mailman join listname"
listname-leave:       "|/system/mailman/bin/mailman leave listname"
listname-owner:       "|/system/mailman/bin/mailman owner listname"
listname-request:     "|/system/mailman/bin/mailman request listname"
listname-subscribe:   "|/system/mailman/bin/mailman subscribe listname"
listname-unsubscribe: "|/system/mailman/bin/mailman unsubscribe listname"
```

#### sudo

Configure `sudo` to allow your mail agent to inject mail into the
container via a Docker command.  The program cited below is the
wrapped half of a pair that the unwrapped half runs with `sudo`.

```
# Sudoers for Mailman container wrapper

Cmnd_Alias MAILMAN_CONTAINER=/system/mailman/bin/mailman-root *
mailnull ALL=(root:root) NOPASSWD:MAILMAN_CONTAINER
Defaults!MAILMAN_CONTAINER !requiretty
```

### Log Rotation

Logs are not currently rotated.  That and external configuration may
be a feature in a future release.
