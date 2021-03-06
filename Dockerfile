ARG BASE=node:10-stretch
FROM $BASE as iobroker

ENV DEBIAN_FRONTEND="teletype" \
	#LANG="de_DE.UTF-8" \
	#LANGUAGE="de_DE:de" \
	#LC_ALL="de_DE.UTF-8" \
	TZ="Europe/Berlin" \
	PACKAGES="nano" \
	AVAHI="false"

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
        acl \
        apt-utils \
        avahi-daemon \
        bash \
        build-essential \
        curl \
        git \
        gnupg2 \
        libavahi-compat-libdnssd-dev \
        libcap2-bin \
        libpam0g-dev \
        libudev-dev \
        locales \
        procps \
        python \
        gosu \
        tzdata \
        unzip \
        vim \
        wget \
      cifs-utils && \
    #See https://github.com/npm/uid-number/issues/3
    npm config set unsafe-perm true && \
    npm install -g node-gyp && \
    echo "Configuring avahi-daemon..." && \
    sed -i '/^rlimit-nproc/s/^\(.*\)/#\1/g' /etc/avahi/avahi-daemon.conf && \
    echo "Configuring dbus..." && \
    mkdir /var/run/dbus/ && \
    apt-get -y clean all

ADD scripts/* /usr/local/bin/

#Trigger build when iobroker package changes
ADD .build/iobroker-stable.md5sum /tmp/
RUN cat /proc/self/cgroup && curl -sL https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh | bash -

RUN getcap $(eval readlink -f `which node`) && \
    iobroker stop && \
    iobroker update && \
    iobroker upgrade self

#The iobroker_data has to be preserved across updates
#VOLUME /opt/iobroker/iobroker-data

EXPOSE 8081 8082 8083 8084
ENTRYPOINT ["run.sh"]
CMD ["start"]

FROM iobroker as full-iobroker

ARG adapters="backitup chromecast daikin dwd feiertage flot fritzdect google-sharedlocations harmony history hm-rega hm-rpc \
              # icons-addictive-flavour-png icons-fatcow-hosting icons-icons8 icons-material-png icons-material-svg \
              # icons-mfd-png icons-mfd-svg icons-open-icon-library-png icons-ultimate-png \
              influxdb iot javascript material mobile openhab rickshaw sayit scenes simple-api sonoff \
              vis vis-bars vis-canvas-gauges vis-colorpicker vis-fancyswitch vis-google-fonts vis-history vis-hqwidgets \
              vis-jqui-mfd vis-justgage vis-lcars vis-map vis-metro vis-players vis-timeandweather vis-weather"

#Install adapters
RUN for adapter in ${adapters}; do iobroker install $adapter; done

#Currently this adapter is missing
RUN iobroker url https://github.com/t4qjXH8N/ioBroker.google-sharedlocations.git
