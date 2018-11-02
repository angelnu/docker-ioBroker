#!/usr/bin/env sh

IOBROKER_CMD="node node_modules/iobroker.js-controller/controller.js $*"

echo "Locatime is $TZ"

cp -av /etc/localtime_host /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

echo "Execute setup"
./iobroker setup

if [ n$1 == nbash ]; then
  echo "Starting shell"
  $*
  exit $?
fi

#Upload files in background
upload.sh &

#Start with PID 1
echo "$IOBROKER_CMD"
exec $IOBROKER_CMD
