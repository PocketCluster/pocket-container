#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

# Tell DPKG not to install documents
if [ ! -d "/etc/dpkg/dpkg.cfg.d/" ]; then
	mkdir /etc/dpkg/dpkg.cfg.d/
fi
cat <<EOM >/etc/dpkg/dpkg.cfg.d/01_nodoc
path-exclude /usr/share/doc/*
# we need to keep copyright files for legal reasons
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
# lintian stuff is small, but really unnecessary
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
# don't autocomplete
path-exclude /usr/share/zsh/vendor-completions/*
path-exclude /usr/share/bash-completion/completions/*
EOM

# tell APT not to install recommends & suggestion
if [ ! -d "/etc/apt/apt.conf.d/" ]; then
	mkdir /etc/apt/apt.conf.d/
fi
cat <<EOM >/etc/apt/apt.conf.d/50singleboards
# Never use pdiffs, current implementation is very slow on low-powered devices
Acquire::PDiffs "0";
EOM
cat <<EOM >$R/etc/apt/apt.conf
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOM

## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Replace the 'ischroot' tool to make it always return true.
## Prevent initscripts updates from breaking /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

# set default shell as bash
chsh -s $(type -p bash) root

# debian package update
echo 'deb http://ftp.debian.org/debian stable main contrib'>> /etc/apt/sources.list && apt-get update
