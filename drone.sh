#!/bin/sh -e
# This updates .drone.yml from .drone.jsonnet and triggers a dev build
#
# It requires the drone.io cli to be installed and a secrets.yml in this folder
# with the following content:
# DOCKER_USER: <docker user>
# DOCKER_PASS: <docker password>

GIT_BRANCH=master
GIT_COMMIT=dev

DRONE_OPTS="--secret-file secrets.yml \
           --branch $GIT_BRANCH \
           --event pull_request"
export DRONE_COMMIT=$GIT_COMMIT
export DRONE_BUILD_NUMBER=99999


case "$(uname -m)" in
    x86_64)
        ARCH=amd64
        ;;
    armv7l)
        ARCH=arm
        ;;
    aarch64)
        ARCH=arm64
        ;;
    *)
        echo "Uknown architecture!"
        ARCH=$(uname -m)
esac

drone jsonnet --stream
drone exec $DRONE_OPTS --pipeline build_full-amd64
drone exec $DRONE_OPTS --pipeline build_full-manifest
