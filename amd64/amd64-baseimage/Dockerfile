FROM debian:stable
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

# init debian docker
RUN echo 'deb http://ftp.debian.org/debian stable main contrib'>> /etc/apt/sources.list &&\
	apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y &&\
	cp -R /usr/share/locale/en\@* /tmp/ &&\
	rm -rf /usr/share/locale/* &&\
	mv /tmp/en\@* /usr/share/locale/ &&\
	rm -rf /var/cache/debconf/*-old &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /usr/share/doc/* && \
	apt-get update -y
