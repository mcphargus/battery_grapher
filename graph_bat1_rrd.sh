#!/bin/bash

rrdtool \
    graphv bat1.png \
    --end now --start end-5h \
    --title "radmax battery level" \
    -w 400 -h 300 \
    DEF:bat1_pct=/home/clint/bat1.rrd:bat1_pct:AVERAGE:step=1 \
    DEF:bat0_pct=/home/clint/bat1.rrd:bat0_pct:AVERAGE:step=1 \
    AREA:bat1_pct#0000ff:"battery 1 level" \
    AREA:bat0_pct#005500:"battery 2 level" \
    AREA:0 \



