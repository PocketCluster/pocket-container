FROM pocketcluster/amd64-baseimage:latest
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

## install java 1.8.0
RUN echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list &&\ 
	apt-get update && apt-get install -y openjdk-8-jre-headless &&\
	update-java-alternatives --set java-1.8.0-openjdk-amd64