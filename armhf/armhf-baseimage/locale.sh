#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests locales

# Setup default locale
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
LC_CTYPE="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_RESPONSE="en_US.UTF-8"
EOM

cat <<EOM >/etc/locale.gen
# This file lists locales that you wish to have built. You can find a list
# of valid supported locales at /usr/share/i18n/SUPPORTED, and you can add
# user defined locales to /usr/local/share/i18n/SUPPORTED. If you change
# this file, you need to rerun locale-gen.

en_US.UTF-8 UTF-8
EOM

for LOCALE in $(locale | cut -d'=' -f2 | grep -v : | sed 's/"//g' | uniq); do
    if [ -n "${LOCALE}" ]; then
        locale-gen $LOCALE
        update-locale LC_ALL=$LOCALE
    fi
done

dpkg-reconfigure --frontend=noninteractive locales

find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*' | xargs rm -rf