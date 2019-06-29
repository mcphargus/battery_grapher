#!/bin/bash

# currently is made to run every minute via a cronjob or while loop.

source /home/clint/Projects/batt_graph/config.sh

bat0=$(acpi | head -n1 | awk '{print $4}' | cut -d% -f1)
bat1=$(acpi | tail -n1 | awk '{print $4}' | cut -d% -f1)

#echo "$bat0 $bat1"

rrdtool \
    update \
    $rrdfile \
    N@$bat0:$bat1

function graph() {
    time=$1
    rrdtool \
    graph $projhome/graph_$time.png \
    -c CANVAS#000000 -c FONT#FFFFFF -c BACK#000000 \
    --end now --start end-$time \
    --title "radmax battery level" \
    -w 400 -h 200 \
    DEF:bat1_pct=$rrdfile:bat1_pct:AVERAGE:step=1 \
    DEF:bat0_pct=$rrdfile:bat0_pct:AVERAGE:step=1 \
    LINE1:bat1_pct#0000ff:"battery 1 level" \
    LINE1:bat0_pct#00ff00:"battery 0 level" \
    LINE1:0 &> /dev/null
}

graph 3h
graph 6h
graph 24h
graph 7d
graph 1M