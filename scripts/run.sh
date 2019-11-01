#!/usr/bin/env sh

cd /opt/iobroker

IOBROKER_CMD="node node_modules/iobroker.js-controller/controller.js $*"

echo "Locatime is $TZ"
date

echo "Execute setup"
iobroker setup

if [ "n$1" = "nbash" ]; then
  echo "Starting shell"
  $*
  exit $?
fi

#Upload files in background
upload.sh &

# Checking for and setting up avahi-daemon
if [ "$avahi" = "true" ]
then
  echo "Starting dbus..."
  dbus-daemon --system

  echo "Starting avahi-daemon..."
  /etc/init.d/avahi-daemon start
fi

#Start with PID 1
echo "$IOBROKER_CMD"
exec $IOBROKER_CMD
