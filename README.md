###### Please note: This is a work in progress and was requested by another user. I haven't been able to fully test all of the functionality as I don't have any printers that use this slicing software.

# CHITUBOX noVNC Docker Container

## Overview

This is a super basic noVNC build using supervisor to serve CHITUBOX in your favorite web browser. This was primarily built for users using the [popular unraid NAS software](https://unraid.net), to allow them to quickly hop in a browser, slice, and upload their favorite 3D prints.

## How to use

### In unraid

If you're using unraid, open your Docker page and under `Template repositories`, add `https://github.com/helfrichmichael/unraid-templates` and save it. You should then be able to Add Container for chitubox-novnc. For unraid, the template will default to 6080 for the noVNC web instance.

### Outside of unraid

#### Docker
To run this image, you can run the following command: `docker run --detach --volume=chitubox-novnc-data:/configs/ --volume=chitubox-novnc-prints:/prints/ -p 8080:8080 -e SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt" 
--name=chitubox-novnc chitubox-novnc`

This will bind `/configs/` in the container to a local volume on my machine named `chitubox-novnc-data`. Additionally it will bind `/prints/` in the container to `superslicer-novnc-prints` locally on my machine, it will bind port `8080` to `8080`, and finally, it will provide an environment variable to keep CHITUBOX happy by providing an `SSL_CERT_FILE`.

#### Docker Compose
To use the pre-built image, simply clone this repository or copy `docker-compose.yml` and run `docker compose up -d`.

To build a new image, clone this repository and run `docker compose up -f docker-compose.build.yml --build -d`

### Using a VNC Viewer

To use a VNC viewer with the container, the default port for X TigerVNC is 5900. You can add this port by adding `-p 5900:5900` to your command to start the container to open this port for access.


### GPU Acceleration/Passthrough

Like other Docker containers, you can pass your Nvidia GPU into the container using the `NVIDIA_VISIBLE_DEVICES` and `NVIDIA_DRIVER_CAPABILITIES` envs. You can define these using the value of `all` or by providing more narrow and specific values. This has only been tested on Nvidia GPUs.

In unraid you can set these values during set up. For containers outside of unraid, you can set this by adding the following params or similar  `-e NVIDIA_DRIVER_CAPABILITIES="all" NVIDIA_VISIBLE_DEVICES="all"`. If using Docker Compose, uncomment the enviroment variables in the relevant docker-compose.yaml file. 


## Links

[CHITUBOX](https://www.chitubox.com/)

[Supervisor](http://supervisord.org/)

[GitHub Source](https://github.com/helfrichmichael/chitubox-novnc)

[Docker](https://hub.docker.com/r/mikeah/chitubox-novnc)

<a href="https://www.buymeacoffee.com/helfrichmichael" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
