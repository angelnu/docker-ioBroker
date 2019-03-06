ARG BASE=node:8-slim
FROM $BASE

ARG arch=arm
ENV ARCH=$arch

ENV TZ=Europe/Berlin

COPY qemu/qemu-$ARCH-static* /usr/bin/

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
      build-essential libavahi-compat-libdnssd-dev libudev-dev libpam0g-dev \
      #libavahi-compat-libdnssd-dev 'linux-headers-*' \
      vim bash python \
      libcap2-bin \
      git \
      #make gcc g++ python udev \
      tzdata \
      cifs-utils && \
    # npm config set unsafe-perm true && \ #See https://github.com/npm/uid-number/issues/3
    # npm install -g npm@latest && \
    curl -sL https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh | sed -e 's/,cap_net_admin//g' | bash - && \
    apt-get -y clean all

#Update npmjs
#RUN setcap cap_net_raw+ep /usr/local/bin/node;
#RUN npm config set unsafe-perm true #See https://github.com/npm/uid-number/issues/3
#RUN npm install -g npm@latest
#RUN setcap cap_net_raw+ep /usr/local/bin/node;

# Install base iobroker
#RUN curl -sL https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh | sed -e 's/cap_net_raw,/cap_net_raw+ip,/g' | bash -

ADD scripts/* /usr/local/bin/

#Adding the line bellow results in a LOT of copies when starting the container
#VOLUME /opt/iobroker

#The iobroker_data has to be preserved across updates
#VOLUME /opt/iobroker/iobroker-data

EXPOSE 8081 8082 8083 8084
ENTRYPOINT ["run.sh"]
CMD ["start"]
