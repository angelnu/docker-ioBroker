#!/bin/sh -e
# This builds
GIT_BRANCH=master
GIT_COMMIT=dev

DRONE_OPTS="--secret-file secrets.yml \
           --branch $GIT_BRANCH \
           --event pull_request"
export DRONE_COMMIT=$GIT_COMMIT

drone jsonnet --stream
drone exec $DRONE_OPTS --pipeline build_amd64
drone exec $DRONE_OPTS --pipeline build_manifest
