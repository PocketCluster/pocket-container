#!/bin/bash
set -ex

# clean apt in legitimate way
apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y --purge 

# slash locales (for debian only)
cp -R /usr/share/locale/en\@* /tmp/ && rm -rf /usr/share/locale/* && mv /tmp/en\@* /usr/share/locale/

rm -f /etc/apt/*.save || true
rm -f /etc/apt/sources.list.d/*.save || true
rm -f /etc/resolvconf/resolv.conf.d/original
rm -f /run/*/*pid || true
rm -f /run/*pid || true
rm -f /run/cups/cups.sock || true
rm -f /run/uuidd/request || true
rm -f /etc/*-
rm -rf /tmp/*
# slash rest of residue
rm -rf /tmp/* 
rm -rf /var/tmp/*
rm -f /var/crash/*
rm -f /var/lib/urandom/random-seed

# remove apt cache
rm -rf /var/cache/debconf/*-old
rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/cache/*
rm -rf /var/lib/log/*
rm -rf /var/cache/apt/pkgcache.bin
rm -rf /var/cache/apt/srcpkgcache.bin
## removing /var/lib/dpkg should be at the last
rm -rf /var/lib/{apt,dpkg,cache,log}/

# remove docs and man instead of brueforce removal, let's left copyright notices
find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
find /usr/share/doc -empty|xargs rmdir || true
rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/*
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*
# remove auto-completion
rm -rf /usr/share/zsh/vendor-completions/*
rm -rf /usr/share/bash-completion/completions/*
mkdir -p /usr/share/info

# Potentially sensitive.
rm -f /root/.bash_history
rm -f /root/.ssh/known_hosts

## self desturction
rm -rf /cleanup.sh
