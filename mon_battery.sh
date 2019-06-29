#!/bin/bash

# currently is made to run every minute via a cronjob or while loop.

source /home/clint/Projects/batt_graph/config.sh

bat0=$(cat /sys/class/power_supply/BAT0/capacity)
bat1=$(cat /sys/class/power_supply/BAT1/capacity)
phbat=$(curl -s https://dweet.io/get/latest/dweet/for/rmphbatt | jq '.with[].content.battery')

# dweet it yo
curl -s -H "Content-Type: application/json" \
    -X POST \
    https://dweet.io/dweet/for/rmlapbat \
    -d@- <<< $(jq -n -c --arg bat0 $bat0 --arg bat1 $bat1 '{bat0: $bat0, bat1: $bat1}')

#echo "$bat0 $bat1"

rrdtool \
    update \
    $rrdfile \
    N@$bat0:$bat1:$phbat

function graph() {
    time=$1
    rrdtool \
    graph $projhome/graph_$time.png \
    -c CANVAS#000000 -c FONT#FFFFFF -c BACK#000000 \
    --end now --start end-$time \
    --title "$(hostname -s) battery level" \
    -w 300 -h 150 \
    DEF:bat1_pct=$rrdfile:bat1_pct:AVERAGE:step=1 \
    DEF:bat0_pct=$rrdfile:bat0_pct:AVERAGE:step=1 \
    LINE3:bat0_pct#00ff00:"battery 0 level" \
    AREA:bat0_pct#00ff0060 \
    LINE3:bat1_pct#0000ff:"battery 1 level" \
    AREA:bat1_pct#0000ff60 \
    LINE1:0 &> /dev/null
}

graph 3h
graph 6h
graph 24h
graph 7d
graph 1M

function graph_phone_battery() {
    time=$1
    rrdtool \
        graph $projhome/graph_phone_$time.png \
        -c CANVAS#000000 -c FONT#FFFFFF -c BACK#000000 \
        --end now --start end-$time \
        --title "phone battery level" \
        -w 300 -h 150 \
        DEF:phbat_pct=$rrdfile:phbat_pct:AVERAGE:step=1 \
        LINE3:phbat_pct#00ff00:"phone battery level" \
        AREA:phbat_pct#00ff0060 \
        LINE1:0 &> /dev/null
}

graph_phone_battery 3h
graph_phone_battery 6h
graph_phone_battery 24h
graph_phone_battery 7d
graph_phone_battery 1M