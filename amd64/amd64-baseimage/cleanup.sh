#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

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

## remove installer specific
rm -rf /bd_build

# slash rest of residue
rm -rf /tmp/* 
rm -rf /var/tmp/*
#rm -f /etc/ssh/ssh_host_*

# remove docs and man instead of brueforce removal, let's left copyright notices
find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
find /usr/share/doc -empty|xargs rmdir || true
rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/*
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*
mkdir -p /usr/share/info

# remove auto-completion
rm -rf /usr/share/zsh/vendor-completions/*
rm -rf /usr/share/bash-completion/completions/*

# Clean up old firmware and modules
rm -f /boot/.firmware_revision || true
rm -rf /boot.bak || true

# non-existent at this poin
rm -rf /lib/modules.bak || true

# Potentially sensitive.
rm -f /root/.bash_history
rm -f /root/.ssh/known_hosts
