## Battery Grapher

Unfortunately trying to find something that simply graphs battery levels on my
laptop has proven to be quite a challenge. There were some older tools
available, but, being older tools, they relied on older technologies. Like APM
vs. the newer ACPI. So, I decided to wire up my own crappy battery grapher.

### ACPI command

It could rely on the sys class fs, but it doesn't. It relies on the acpi
command. The output of the acpi command is simple enough that I can parse it
easily and feed it into a little rrdtool database. Gets the job done with no
bells or whistles.

And so, here it is. The RRA's resolution could be better, and I'm always worried
about messing with that because it means I have to blow the current db away and
start a fresh one, with no data. Moving the data between RRD databases is
something I plan on learning how to do.

## /sys/class/

Stared at /sys/class/power_supply a little longer and it became pretty obvious
that the value in /sys/class/power_supply/$BATX/capacity is the percentage of
capacity left, so I should retrofit this thing to use /sys/class rather than
acpi command. Another day maybe.