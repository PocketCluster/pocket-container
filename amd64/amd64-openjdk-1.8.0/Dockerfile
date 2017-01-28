FROM pocketcluster/amd64-baseimage:latest
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

## install java 1.8.0 (let's move dpkg doc restriction for a while)
RUN mv /etc/dpkg/dpkg.cfg.d/01_nodoc ~ &&\
	mv /etc/apt/apt.conf ~ &&\
# add repository	
	echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list &&\ 
	apt-get update && apt-get install -y openjdk-8-jre-headless &&\
	update-java-alternatives --set java-1.8.0-openjdk-amd64 &&\
# move back dpkg restriction	
    mv ~/01_nodoc /etc/dpkg/dpkg.cfg.d/ &&\
	mv ~/apt.conf /etc/apt/ &&\
# clean documents	
	rm -rf /usr/lib/jvm/java-8-openjdk-amd64/man || true &&\
	rm -rf /usr/lib/jvm/java-8-openjdk-amd64/jre/man || true &&\
	rm -rf /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/images/cursors/*.gif || true &&\
	find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true &&\
	find /usr/share/doc -empty|xargs rmdir || true &&\	
	rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/* &&\
	rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* &&\
	mkdir -p /usr/share/info &&\
# clean cache
	rm -rf /var/lib/apt/lists/* &&\
	apt-get clean &&\
	apt-get autoremove --purge -y