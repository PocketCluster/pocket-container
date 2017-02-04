#!/usr/bin/env bash

# remove dpkg restriction
mv /etc/dpkg/dpkg.cfg.d/01_nodoc ~
# mv /etc/apt/apt.conf ~

# install dependencies
echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list &&\
    apt-get update &&\
    apt-get install -y build-essential g++ autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev maven curl autoconf &&\
    apt-get install -y openjdk-8-jdk &&\
    apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y

export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::")

# extract protobuf-2.5.0 and install
tar xvzf /protobuf-src-2.5.0.tar.gz -C /tmp &&
# extract gtest and embed in protobuf
    tar xvzf /gtest-1.5.0.tar.gz -C /tmp &&\
    mv /tmp/googletest-release-1.5.0 /tmp/protobuf-2.5.0/gtest &&\
    cd /tmp/protobuf-2.5.0 &&\
    ./autogen.sh &&\
    ./configure --prefix=/usr &&\
    make &&\
    make check &&\
    make install &&\
    protoc --version &&\
    cd java &&\
    mvn install &&\
    mvn package -DskipTests

# build hadoop lib and copy the library
tar xvzf /hadoop-2.6.5-src.tar.gz -C /tmp &&\
    cd /tmp/hadoop-2.6.5-src &&\
    mvn package -Pdist,native -DskipTests -Dtar &&\
    cp -rf /tmp/hadoop-2.6.5-src/hadoop-dist/target/hadoop-2.6.5/lib/native/* /native/
