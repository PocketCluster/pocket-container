FROM armhf/debian:stable
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

# Prepare files
COPY ezdk-1.8.0_102-8.17.0.21-eval-linux_aarch32hf.tar.gz /
COPY ezdk-1.8.0-102-java-post-install.sh /
COPY protobuf-src-2.5.0.tar.gz /
COPY hadoop-2.6.5-src.tar.gz /
COPY gtest-1.5.0.tar.gz /
COPY libcompile.sh /

RUN chmod +x /libcompile.sh

CMD ["/libcompile.sh"]