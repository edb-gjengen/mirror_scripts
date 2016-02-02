#/bin/bash
#RSYNCSOURCE=rsync://ftp5.gwdg.de/pub/linux/archlinux/
#RSYNCSOURCE=rsync://mirror.nl.leaseweb.net/archlinux/
RSYNCSOURCE=rsync://mirror.one.com/archlinux/
#RSYNCSOURCE=rsync://mirror.neuf.no/archlinux/

# Define where you want the mirror-data to be on your mirror
BASEDIR=/store/mirror/archlinux

rsync --verbose --recursive --times --links --hard-links \
  --stats --delete-after --ignore-errors \
  ${RSYNCSOURCE} ${BASEDIR} &>> /opt/scripts/archlinux.log || echo "Failed to rsync from ${RSYNCSOURCE}."

date &>> /opt/scripts/archlinux.log
echo "############################" &>> /opt/scripts/archlinux.log

