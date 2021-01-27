#!/bin/bash

# currently is made to run every minute via a cronjob or while loop.

source /home/clint/Projects/batt_graph/config.sh

bat0_cap=$(cat /sys/class/power_supply/BAT0/capacity)
bat1_cap=$(cat /sys/class/power_supply/BAT1/capacity)
bat0_volt=$(cat /sys/class/power_supply/BAT0/voltage_now)
bat1_volt=$(cat /sys/class/power_supply/BAT1/voltage_now)
bat0_status=$(cat /sys/class/power_supply/BAT0/status)
bat1_status=$(cat /sys/class/power_supply/BAT1/status)
phbat_cap=$(curl -s https://dweet.io/get/latest/dweet/for/rmphbatt | jq '.with[].content.battery')

# dweet it yo
bat_data=$(jq -n -c \
    --arg hostname $(hostname -s) \
    --arg bat0_cap $bat0_cap \
    --arg bat1_cap $bat1_cap \
    --arg bat1_volt $bat1_volt \
    --arg bat0_volt $bat0_volt \
    --arg bat0_status $bat0_status \
    --arg bat1_status $bat1_status \
    '{
        bat0: $bat0_cap,
        bat1: $bat1_cap,
        hostname: $hostname,
        bat1_volt: $bat1_volt,
        bat0_volt: $bat0_volt,
        bat1_status: $bat1_status,
        bat0_status: $bat0_status
    }'
)

curl -s -H "Content-Type: application/json" \
    -X POST \
    https://dweet.io/dweet/for/rmlapbat \
    -d@- <<< $bat_data

rrdtool \
    update \
    $rrdfile \
    N@$bat0_cap:$bat1_cap:$phbat_cap:$bat0_volt:$bat1_volt

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

function graph_laptop_voltage() {
    time=$1
    rrdtool \
        graph $projhome/graph_laptop_voltage_$time.png \
        -c CANVAS#000000 -c FONT#FFFFFF -c BACK#000000 \
        --end now --start end-$time \
        --title "$hostname battery voltage level" \
        -w 300 -h 150 \
        DEF:bat0v=$rrdfile:bat0v:AVERAGE:step=1 \
        DEF:bat1v=$rrdfile:bat1v:AVERAGE:step=1 \
        CDEF:bat0V=bat0v,0.000001,* \
        CDEF:bat1V=bat1v,0.000001,* \
        LINE3:bat0V#00ff00:"battery 0" \
        LINE3:bat1V#0000ff:"battery 1" 
}

graph_laptop_voltage 3h
graph_laptop_voltage 6h
graph_laptop_voltage 24h
graph_laptop_voltage 7d
graph_laptop_voltage 1M