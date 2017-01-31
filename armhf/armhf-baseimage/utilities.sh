#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## This tool runs a command as another user and sets $HOME.
cp /bd_build/bin/setuser /sbin/setuser
