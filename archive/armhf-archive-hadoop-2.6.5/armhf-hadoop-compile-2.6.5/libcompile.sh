#!/usr/bin/env bash

# install dependencies
#echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list &&\
apt-get update
apt-get install -y build-essential g++ autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev maven curl autoconf
#apt-get install -y libprotobuf-lite9 libprotobuf9 protobuf-compiler libprotobuf-java libprotobuf-dev
apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y

## install java 1.8.0
mkdir -p /opt &&\
    tar -xzf /ezdk-1.8.0_102-8.17.0.21-eval-linux_aarch32hf.tar.gz &&\
    mv /ezdk-1.8.0_102-8.17.0.21-eval-linux_aarch32hf /opt/jdk &&\
    chown -R root:root /opt/jdk

export JAVA_HOME="/opt/jdk"

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
    ldconfig &&\
    protoc --version &&\
    cd java &&\
    mvn install &&\
    mvn package -DskipTests

# copy the whiole directory for packaging
cp -rf /tmp/protobuf-2.5.0/* /protobuf-native/

# build hadoop lib and copy the library
tar xvzf /hadoop-2.6.5-src.tar.gz -C /tmp &&\
    cd /tmp/hadoop-2.6.5-src &&\
#    mvn package -Pdist,native -DskipTests -Dtar &&\
    mvn clean package -Pdist,native -DskipTests -Dtar -Dmaven.javadoc.skip=true

# copy the compiled lib for packaging
cp -rf /tmp/hadoop-2.6.5-src/hadoop-dist/target/hadoop-2.6.5/lib/native/* /hadoop-native/
