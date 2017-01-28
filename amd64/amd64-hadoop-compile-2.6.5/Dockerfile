FROM pocketcluster/amd64-baseimage:latest
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

COPY protobuf-src-2.5.0.tar.gz /
COPY hadoop-2.6.5-src.tar.gz /
COPY gtest-1.5.0.tar.gz /
COPY libcompile.sh /
RUN chmod +x /libcompile.sh

CMD ["/libcompile.sh"]