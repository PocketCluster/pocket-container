FROM armhf/debian:stable
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# ROOT USER
USER root

ADD . /bd_build

RUN chmod +x /bd_build/*.sh &&\
    /bd_build/prepare.sh &&\
    /bd_build/locale.sh &&\
    /bd_build/essentials.sh &&\
	/bd_build/system_services.sh &&\
	/bd_build/cleanup.sh

CMD ["/sbin/my_init"]
