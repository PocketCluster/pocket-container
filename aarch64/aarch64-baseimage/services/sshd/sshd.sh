#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

SSHD_BUILD_PATH=/bd_build/services/sshd

## Install the SSH server.
$minimal_apt_get_install openssh-server
mkdir /var/run/sshd
mkdir /etc/service/sshd

cp $SSHD_BUILD_PATH/sshd.runit /etc/service/sshd/run
cp $SSHD_BUILD_PATH/sshd_config /etc/ssh/sshd_config
cp $SSHD_BUILD_PATH/00_regen_ssh_host_keys.sh /etc/my_init.d/

## Make default SSH key path
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chown root:root /root/.ssh
