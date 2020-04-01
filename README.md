# COD4 Docker dedicated server

*Call of duty 4 dedicated server with full Steam support*

[![Docker Cod4](https://github.com/skrtheboss/cod4-docker/raw/master/images/title.png)](https://hub.docker.com/r/skrtheboss/cod4/)

[![Docker Build Status](https://img.shields.io/docker/build/skrtheboss/cod4.svg)](https://hub.docker.com/r/skrtheboss/cod4)

[![GitHub last commit](https://img.shields.io/github/last-commit/skrtheboss/cod4-docker.svg)](https://github.com/skrtheboss/cod4-docker/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/skrtheboss/cod4-docker.svg)](https://github.com/skrtheboss/cod4-docker/issues)
[![GitHub issues](https://img.shields.io/github/issues/skrtheboss/cod4-docker.svg)](https://github.com/skrtheboss/cod4-docker/issues)

[![Docker Pulls](https://img.shields.io/docker/pulls/skrtheboss/cod4.svg)](https://hub.docker.com/r/skrtheboss/cod4)
[![Docker Stars](https://img.shields.io/docker/stars/skrtheboss/cod4.svg)](https://hub.docker.com/r/skrtheboss/cod4)
[![Docker Automated](https://img.shields.io/docker/automated/skrtheboss/cod4.svg)](https://hub.docker.com/r/skrtheboss/cod4)

[![Image size](https://images.microbadger.com/badges/image/skrtheboss/cod4.svg)](https://microbadger.com/images/skrtheboss/cod4)
[![Image version](https://images.microbadger.com/badges/version/skrtheboss/cod4.svg)](https://microbadger.com/images/skrtheboss/cod4)

| Image size | RAM usage | CPU usage |
| --- | --- | --- |
| 180MB | 120MB to 250MB | Low |

It is based on:

- [Minideb](https://github.com/bitnami/minideb) A minimalist Debian-based image built specifically to be used as a base image for containers.
- [Cod4x](https://github.com/callofduty4x/CoD4x_Server) server built from source

## Requirements

- COD4 Client game
- COD4 running on version 1.7 have to [update to 1.8](https://cod4x.me/index.php?/forums/topic/12-how-to-install-cod4x/)
- Original COD4 **main** and **zone** files required (from the client installation directory)

## Features

- **21MB** image
- [Cod4x server features](https://github.com/callofduty4x/CoD4x_Server#the-most-prominent-features-are)
- Works with custom mods and maps (see the [Mods section](#Mods))
- Full support for steam_api (see the [Steam API](#SteamAPI))
- Easily configurable with [docker-compose](https://raw.githubusercontent.com/skrtheboss/cod4-docker/master/docker-compose.yml)
- Runs without root (safer)
- Run a lightweight NGINX HTTP server for your clients to download your mods and usermaps with docker-compose.yml
- Default cod4 configuration file [server.cfg](https://github.com/skrtheboss/cod4-docker/blob/master/server.cfg)
    - Placed into `./main`
    - Launched by default when not using mods with `exec server.cfg`
    - Easily changeable

## Setup

We assume your *call of duty 4 game* is installed at `/mycod4path`

1. On your host, create the directories `./main`, `./zone`, `./mods` and `./usermaps`.
1. From your Call of Duty 4 installation directory:
    - Copy all the `.iwd` files from `/mycod4path/main` to `./main`
    - Copy all the files from `/mycod4path/zone` to `./zone`
    - (Optional) Copy the mods you want to use from `/mycod4path/mods` to `./mods`
    - (Optional) Copy the maps you want to use from `/mycod4path/usermaps` to `./usermaps`
1. As the container runs as user ID 1000 by default, fix the ownership and permissions:

    ```bash
    chown -R 1000 main mods usermaps zone
    chmod -R 700 main mods usermaps zone
    ```

    You can also run the container with `--user="root"` (unadvised!)

1. Run the following command as root user on your host:

    ```bash
    docker run -d --name=cod4 -p 28960:28960/udp \
        -v $(pwd)/main:/home/user/cod4/main \
        -v $(pwd)/zone:/home/user/cod4/zone:ro \
        -v $(pwd)/mods:/home/user/cod4/mods \
        -v $(pwd)/usermaps:/home/user/cod4/usermaps:ro \
        -v $(pwd)/cod4-server-1:/home/user/.callofduty \ # Optional `.callofduty` is the default sv_homepath
        -v $(pwd)/cod4-server-1/screenshots:/home/user/cod4/screenshots \ # Optional save screenshots on an external path
        skrtheboss/cod4 +map mp_crash
    ```

    The command line argument `+map mp_crash` is optional and defaults to `+set dedicated 2+exec server.cfg+map_rotate`

    You can also download and modify the [*docker-compose.yml*](https://raw.githubusercontent.com/skrtheboss/cod4-docker/master/docker-compose.yml) file and run

    ```bash
    docker-compose up -d
    ```

### HTTP server for custom mods and maps

1. Locate the relevant configuration file - for example `main/server.cfg` or `mods/mymod/server.cfg`
1. Modify/add the following lines & change `fastdownload.your-domain.com` to your IP or domain name:

    ```c
    set sv_allowdownload "1"
    set sv_wwwDownload "1"
    set sv_wwwBaseURL "http://fastdownload.your-domain.com/cod4" // supports http, https and ftp addresses
    set sv_wwwDlDisconnected "0"
    ```

1. Uncomment the HTTP section in the the [*docker-compose.yml*](https://raw.githubusercontent.com/skrtheboss/cod4-docker/master/docker-compose.yml) file and run

    ```bash
    docker-compose up -d
    ```

2. You will have to setup port forwarding on your router. Ask me or Google if you need help.

## Mods

Assuming:

- Your mod directory is `./mod_name`
- Your main mod configuration file is `./main/mod_name/server.cfg`

Set the command line option to `+set dedicated 2+set fs_game mods/mod_name+exec mod_name/server.cfg+map_rotate`

## SteamAPI

- Required for player authentication, screenshots and many other essential features

## Write protected args

The following parameters are write protected and **can't be placed in the server configuration file**,
and must be in the `ARGS` environment variable:

- `+set dedicated 2` - 2: open to internet, 1: LAN, 0: localhost
- `+set sv_cheats "1"` - 1 to allow cheats, 0 otherwise
- `+set sv_maxclients "64"` - number of maximum clients
- `+exec server.cfg` if using a configuration file
- `+set fs_game mods/mymod` if using a custom mod
- `+set com_hunkMegs "512"` don't use if not needed
- `+set net_ip 127.0.0.1` don't use if not needed
- `+set net_port 28961` don't use if not needed
- `+map_rotate` OR i.e. `+map mp_shipment` **should be the last launch argument**

## TODOs

- Env variables for plugins etc.
- Plugins (see https://hub.docker.com/r/callofduty4x/cod4x18-server/)
- Easily switch between mods: script file or management tool
- Built-in mods?

## Acknowledgements

- Credits to the developers of Cod4x server
- The help I had on [Cod4x.me forums](https://cod4x.me/index.php?/forums/)
