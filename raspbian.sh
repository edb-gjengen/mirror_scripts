#!/bin/bash

logfile='/var/log/mirror/raspbian.log'

fatal() {
    echo "$1"
    echo -e "Last lines from log:\n"
    tail $logfile
    exit 1
}

home="/store"
target="${home}/mirror/raspbian"
lock='/tmp/raspbiansync.lck'
source='rsync://archive.raspbian.org/archive'

[ ! -d "${target}" ] && mkdir -p "${target}"

exec 9>"${lock}"
flock -n 9 || exit

# only run rsync when there are changes
	rsync -rtlvH --safe-links --delete-after --progress -h --timeout=600 --contimeout=60 -p \
		--delay-updates --no-motd \
		${source} \
		"${target}" &>> $logfile || fatal "Failed to sync." 

date >> $logfile


