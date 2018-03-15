FROM pc-master:5000/x86_64-baseimage:latest
MAINTAINER PocketCluster <stkim1@pocketcluster.io>

# ROOT USER
USER root

## install java 1.8.0 (let's move dpkg doc restriction for a while)
RUN	apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
	ca-certificates-java openjdk-8-jre-headless && \
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