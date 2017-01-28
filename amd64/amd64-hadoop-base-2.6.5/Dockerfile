FROM pocketcluster/amd64-openjdk-1.8.0:latest
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

# Prepare files
COPY bashrc /
COPY config /
COPY id_rsa* /
COPY hadoop-2.6.5.tar.gz /
COPY hadoop-native-lib-2.6.5.tar.gz /

# install openssh-server
RUN apt-get update &&\
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends net-tools libssl1.0.0 libsnappy1 &&\
	apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y &&\
	rm -rf /var/lib/{apt,dpkg,cache,log}/

#configure ssh free key access
RUN mkdir -p /var/run/sshd &&\
	mkdir -p $HOME/.ssh &&\
	mv /id_rsa* $HOME/.ssh &&\
	cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys &&\
	mv /config $HOME/.ssh/config &&\
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#install hadoop 2.6.5
RUN tar -xzf /hadoop-2.6.5.tar.gz &&\
    rm /hadoop-2.6.5.tar.gz &&\
    mv /hadoop-2.6.5 /opt/hadoop &&\
## move native library
	rm /opt/hadoop/lib/native/* &&\
	tar -xzf /hadoop-native-lib-2.6.5.tar.gz -C /opt/hadoop/lib/native &&\
## cleanup
	rm /hadoop-native-lib-2.6.5.tar.gz &&\
	rm /opt/hadoop/bin/*.cmd &&\
	rm /opt/hadoop/sbin/*.cmd &&\
	rm /opt/hadoop/etc/hadoop/*.cmd &&\
	rm /opt/hadoop/libexec/*.cmd &&\
## ownership need to be adjusted at later version	
	chown -R root:root /opt/hadoop/ &&\
## setup
	mkdir -p /etc/hadoop &&\
	cp /opt/hadoop/etc/hadoop/* /etc/hadoop/ &&\
	rm /etc/hadoop/slaves &&\
## base hadoop env variables	
	mv /bashrc $HOME/.bashrc &&\
## link libraries for native performance
	ln -sf /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu/libcrypto.so

COPY etc-hadoop/* /etc/hadoop/

EXPOSE 22 7373 7946 8030 8031 8032 8033 8040 8042 8060 8088 9000 10020 19888 50010 50020 50060 50070 50075 50090 50475 54310 54311