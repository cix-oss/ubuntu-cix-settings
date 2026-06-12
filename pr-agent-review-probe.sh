#!/bin/sh

# Temporary PR-Agent review probe. Do not merge this file.
LOG=/tmp/cix-probe.log

echo starting probe for $USER > $LOG
systemctl restart bluetooth
cp $1 /usr/local/share/cix-probe/
