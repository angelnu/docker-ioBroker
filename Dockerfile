ARG BASE=node:10-stretch
FROM $BASE as iobroker

ENV TZ=Europe/Berlin

#COPY qemu/qemu-*-static* /usr/bin/

# inspired by https://github.com/iobroker/docker-iobroker
MAINTAINER Vegetto <git@angelnu.com>

# Install required dependencies for the adapters
# See: https://github.com/ioBroker/ioBroker/wiki/Installation
# git: needed to download beta adapters
# avahi-dev: needed by mdns (iobroker.chromecast)
# make gcc g++ python linux-headers udev: needed by serialport (iobroker.discovery) - https://www.npmjs.com/package/serialport#platform-support
#RUN apk add --no-cache \
#      build-base avahi-dev linux-headers \
RUN apt-get update && apt-get install -y \
      apt-utils build-essential libavahi-compat-libdnssd-dev libudev-dev libpam0g-dev \
      #libavahi-compat-libdnssd-dev 'linux-headers-*' \
      vim bash python \
      libcap2-bin \
      git \
      #make gcc g++ python udev \
      tzdata \
      cifs-utils && \
    # npm config set unsafe-perm true && \ #See https://github.com/npm/uid-number/issues/3
    # npm install -g npm@latest && \
    apt-get -y clean all

ADD scripts/* /usr/local/bin/

#Trigger build when iobroker package changes
ADD .build/iobroker-stable.md5sum /tmp/
RUN curl -sL https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh | sed -e 's/,cap_net_admin//g' | bash -

#The iobroker_data has to be preserved across updates
#VOLUME /opt/iobroker/iobroker-data

EXPOSE 8081 8082 8083 8084
ENTRYPOINT ["run.sh"]
CMD ["start"]

FROM iobroker as full-iobroker

ARG adapters="backitup chromecast daikin dwd feiertage flot fritzdect google-sharedlocations harmony history hm-rega hm-rpc \
              # icons-addictive-flavour-png icons-fatcow-hosting icons-icons8 icons-material-png icons-material-svg \
              # icons-mfd-png icons-mfd-svg icons-open-icon-library-png icons-ultimate-png \
              influxdb iot javascript material mobile openhab rickshaw sayit scenes simple-api \
              vis vis-bars vis-canvas-gauges vis-colorpicker vis-fancyswitch vis-google-fonts vis-history vis-hqwidgets \
              vis-jqui-mfd vis-justgage vis-lcars vis-map vis-material vis-metro vis-players vis-timeandweather vis-weather"

#Install adapters
RUN for adapter in ${adapters}; do iobroker install $adapter; done
