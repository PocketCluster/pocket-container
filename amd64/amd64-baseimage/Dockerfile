FROM debian:stable
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

ADD . /bd_build

RUN /bd_build/prepare.sh && \
    /bd_build/locale.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
	/bd_build/cleanup.sh

CMD ["/sbin/my_init"]
