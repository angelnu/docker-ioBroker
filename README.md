# docker-iobroker
[![Downloads](https://img.shields.io/docker/pulls/angelnu/iobroker.svg)](https://hub.docker.com/r/angelnu/iobroker/)
[![Build Status](https://cloud.drone.io/api/badges/angelnu/docker-ioBroker/status.svg)](https://cloud.drone.io/angelnu/docker-ioBroker)

iobroker as docker container for [mutiple archs](https://hub.docker.com/r/angelnu/iobroker/tags):
- arm
- arm64
- amd64

## How to run
### Docker
You have two options:
- clean install: `docker run -d <any port you want to open> angelnu/iobroker`
- preinstalled adapters: `docker run -d <any port you want to open> angelnu/iobroker:full-latest`

### Kubernetes
See [example](kubernetes.yaml)


## Automated builds
This repository is built with [drone.io](https://drone.io/).

You can execute locally with [drone.sh](drone.sh) (please check the [header](drone.sh) for dependencies).

If you set your own automated build you need to set the following secrets:
- DOCKER_USER: <your docker user>
- DOCKER_PASS: <your docker password>
