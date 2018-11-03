#!/usr/bin/env sh

IOBROKER_CMD="node node_modules/iobroker.js-controller/controller.js $*"

echo "Locatime is $TZ"
date

echo "Execute setup"
./iobroker setup

if [ "n$1" == "nbash" ]; then
  echo "Starting shell"
  $*
  exit $?
fi

#Upload files in background
upload.sh &

#Start with PID 1
echo "$IOBROKER_CMD"
exec $IOBROKER_CMD
