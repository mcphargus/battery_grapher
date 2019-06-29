#!/bin/bash

source config.sh

if [ -e $rrdfile ]
then
    cp $rrdfile rrdbackup/$(basename $rrdfile)_$(date +%s)
else
    echo "$rrdfile doesn't exist, no rrd to backup"
fi

rrdtool \
    create $rrdfile \
    --start now-1h \
    --step 1 \
    DS:bat1_pct:GAUGE:300:0:3000 \
    DS:bat0_pct:GAUGE:300:0:3000 \
    RRA:AVERAGE:0.5:1:3h \
    RRA:AVERAGE:0.5:60:6h \
    RRA:AVERAGE:0.5:300:24h \
    RRA:AVERAGE:0.5:600:7d \
    RRA:AVERAGE:0.5:15m:1M \
