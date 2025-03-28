FROM alpine:3.21.3

LABEL maintainer="miutaku@miutaku.dev"

ENV NUT_VERSION=2.8.2
ENV NUT_MAJOR_VERSION=2.8


ENV UPS_NAME="ups"
ENV UPS_DESC="UPS"
ENV UPS_DRIVER="usbhid-ups"
ENV UPS_PORT="auto"


ENV SHUTDOWN_CMD="echo 'System shutdown not configured!'"

RUN set -ex && \
	# run dependencies
	apk add --no-cache \
		openssh-client \
		libusb-compat \
		nss && \
	# build dependencies
	apk add --update --no-cache --virtual .build-deps \
		libusb-compat-dev \
        net-snmp-dev \
        openssl-dev \
        nss-dev \
        neon-dev \
		build-base && \
	# download and extract
	cd /tmp && \
	wget http://www.networkupstools.org/source/${NUT_MAJOR_VERSION}/nut-${NUT_VERSION}.tar.gz && \
	tar xfz nut-${NUT_VERSION}.tar.gz && \
	cd nut-${NUT_VERSION} && \
	# build
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc/nut \
		--disable-dependency-tracking \
		--enable-strip \
		--disable-static \
		--with-all=no \
		--with-usb=yes \
		--datadir=/usr/share/nut \
		--with-nss \
		--with-openssl \
		--with-neon \
		--with-snmp \
		--with-drvpath=/usr/share/nut \
		--with-statepath=/var/run/nut \
		--with-user=nut \
		--with-group=nut && \
# install
	make install && \
	# create nut user
	adduser -D -h /var/run/nut nut && \
	chgrp -R nut /etc/nut && \
	chmod -R o-rwx /etc/nut && \
	install -d -m 750 -o nut -g nut /var/run/nut && \
	# cleanup
	rm -rf /tmp/nut-${NUT_VERSION}.tar.gz /tmp/nut-${NUT_VERSION} && \
	apk del .build-deps

COPY src/docker-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-entrypoint"]

WORKDIR /var/run/nut

EXPOSE 3493
