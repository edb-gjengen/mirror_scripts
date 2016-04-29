#!/bin/bash

fatal() {
    echo "$1"
    exit 1
}

home="/store"
target="${home}/mirror/archlinux"
tmp="${home}/tmp"
lock='/tmp/mirrorsync.lck'
bwlimit=4096
# NOTE: you very likely need to change this since rsync.archlinux.org requires you to be a tier 1 mirror
source='rsync://rsync.archlinux.org/ftp_tier1'
lastupdate_url="http://rsync.archlinux.org/lastupdate"

[ ! -d "${target}" ] && mkdir -p "${target}"
[ ! -d "${tmp}" ] && mkdir -p "${tmp}"

exec 9>"${lock}"
flock -n 9 || exit

# only run rsync when there are changes
if diff -b <(curl -s "$lastupdate_url") "$target/lastupdate" >/dev/null; then
	echo "Sync was not needed" >> /opt/scripts/archlinux.log
	date +%s > $target/lastsync
else
	echo "Syncing" >> /opt/scripts/archlinux.log

	if ! stty &>/dev/null; then
		QUIET="-q"
	fi

	rsync -rtlvH --safe-links --delete-after --progress -h ${QUIET} --timeout=600 --contimeout=60 -p \
		--delay-updates --no-motd --bwlimit=$bwlimit \
		--temp-dir="${tmp}" \
		--exclude='*.links.tar.gz*' \
		${source} \
		"${target}" &>> /opt/scripts/archlinux.log || fatal "Failed to sync, se /opt/scripts/archlinux.log for more info." 
fi

echo "Last sync was $(date -d @$(cat ${target}/lastsync))" >> /opt/scripts/archlinux.log


