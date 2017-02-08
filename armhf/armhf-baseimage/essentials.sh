#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Install add-apt-repository
#$minimal_apt_get_install software-properties-common

## Upgrade all packages.
#apt-get dist-upgrade -y --no-install-recommends

## basic net tools and certificates
$minimal_apt_get_install apt-utils net-tools ca-certificates

## My_INIT pre-requisite
$minimal_apt_get_install python3-minimal libpython3-stdlib

## Install runit.
$minimal_apt_get_install runit
