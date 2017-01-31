FROM pocketcluster/armhf-baseimage:latest
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

# Prepare files
COPY ezdk-1.8.0_102-8.17.0.21-eval-linux_aarch32hf.tar.gz /
COPY ezdk-1.8.0-102-java-post-install.sh /

## install java 1.8.0
RUN mkdir -p /opt &&\
    tar -xzf /ezdk-1.8.0_102-8.17.0.21-eval-linux_aarch32hf.tar.gz &&\
    mv /ezdk-1.8.0_102-8.17.0.21-eval-linux_aarch32hf /opt/jdk &&\
    rm /ezdk-1.8.0_102-8.17.0.21-eval-linux_aarch32hf.tar.gz &&\
    rm -rf /opt/jdk/*src.zip &&\
    rm -rf /opt/jdk/man/ &&\
    rm -rf /opt/jdk/sample/ &&\
    rm -rf /opt/jdk/demo/ &&\
    chown -R root:root /opt/jdk &&\
    /bin/bash /ezdk-1.8.0-102-java-post-install.sh &&\
    rm /ezdk-1.8.0-102-java-post-install.sh
