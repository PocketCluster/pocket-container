#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

# Setup default locale again as it would be mangled by locale-gen, dpkg-reconfigure
cat <<EOM >/etc/default/locale
LANG="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_RESPONSE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
EOM

cat <<EOM >/etc/locale.gen
# This file lists locales that you wish to have built. You can find a list
# of valid supported locales at /usr/share/i18n/SUPPORTED, and you can add
# user defined locales to /usr/local/share/i18n/SUPPORTED. If you change
# this file, you need to rerun locale-gen.

en_US.UTF-8 UTF-8
EOM

# slash locales (for debian only)
cp -R /usr/share/locale/en\@* /tmp/ && rm -rf /usr/share/locale/* && mv /tmp/en\@* /usr/share/locale/

# clean apt in legitimate way
apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y --purge 

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
#rm -rf /var/lib/{apt,dpkg,cache,log}/

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

## remove installer specific
rm -rf /bd_build
