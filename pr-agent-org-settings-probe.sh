#!/bin/sh

# Temporary PR-Agent organization settings probe. Do not merge this file.
SOURCE=/home/claystan/cix-repo/private-driver
OUT=/tmp/cix-org-settings-probe.log

echo importing from $SOURCE > $OUT
cp $SOURCE/*.ko ./firmware/
