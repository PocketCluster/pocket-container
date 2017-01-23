FROM pocket/armhf-hadoop-datanode:2.6.5
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

USER root

# Spark specific bashrc
COPY bashrc /
COPY spark-2.1.0-bin-without-hadoop.tgz /

#install spark 2.1.0
RUN tar -xzf /spark-2.1.0-bin-without-hadoop.tgz &&\
    rm /spark-2.1.0-bin-without-hadoop.tgz &&\
    mv /spark-2.1.0-bin-without-hadoop /opt/spark &&\
## cleanup
	rm -rf /opt/spark/data &&\
	rm -rf /opt/spark/examples &&\
## setup
	mkdir -p /etc/spark &&\
## base spark env variables	
	cat /bashrc >> $HOME/.bashrc &&\
	rm /bashrc

COPY etc-spark/* /etc/spark/