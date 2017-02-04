FROM pocketcluster/amd64-baseimage:latest
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

COPY openjdk-8-jre-headless_8u121-b13-1~bpo8+1_amd64.deb /
COPY ca-certificates-java_20161107~bpo8+1_all.deb /

## install java 1.8.0 (let's move dpkg doc restriction for a while)
RUN mv /etc/dpkg/dpkg.cfg.d/01_nodoc ~ &&\
	mv /etc/apt/apt.conf ~ &&\
# add repository	
# since backports caused so much issues, we're to block it for now
#	echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list &&\ 
	apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
	fontconfig-config fonts-dejavu-core java-common \
	libasyncns0 libavahi-client3 libavahi-common-data libavahi-common3 libcups2 \
	libdbus-1-3 libflac8 libfontconfig1 libfreetype6 libgmp10 libgnutls-deb0-28 \
	libhogweed2 libice6 libjpeg62-turbo libjson-c2 liblcms2-2 libnettle4 \
	libnspr4 libnss3 libogg0 libp11-kit0 libpcsclite1 libpng12-0 libpulse0 \
	libsctp1 libsm6 libsndfile1 libtasn1-6 libvorbis0a libvorbisenc2 libx11-6 \
	libx11-data libx11-xcb1 libxau6 libxcb1 libxdmcp6 libxext6 libxi6 libxtst6 \
	tzdata-java ucf x11-common libxrender1 &&\
# force install backport files
	dpkg -i --force-all /ca-certificates-java_20161107~bpo8+1_all.deb || true &&\
	rm /ca-certificates-java_20161107~bpo8+1_all.deb &&\
	dpkg -i --force-all /openjdk-8-jre-headless_8u121-b13-1~bpo8+1_amd64.deb &&\
	rm /openjdk-8-jre-headless_8u121-b13-1~bpo8+1_amd64.deb &&\
	apt-get -f install &&\
	update-java-alternatives --set java-1.8.0-openjdk-amd64 &&\
# move back dpkg restriction
    mv ~/01_nodoc /etc/dpkg/dpkg.cfg.d/ &&\
	mv ~/apt.conf /etc/apt/ &&\
# clean documents	
	rm -rf /usr/lib/jvm/java-8-openjdk-amd64/man || true &&\
	rm -rf /usr/lib/jvm/java-8-openjdk-amd64/jre/man || true &&\
	rm -rf /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/images/cursors/*.gif || true &&\
	find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true &&\
	find /usr/share/doc -empty|xargs rmdir || true &&\	
	rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/* &&\
	rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* &&\
	mkdir -p /usr/share/info &&\
# clean cache
	rm -rf /var/lib/apt/lists/* &&\
	apt-get clean &&\
	apt-get autoremove --purge -y