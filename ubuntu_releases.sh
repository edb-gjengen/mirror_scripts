#/bin/dash

fatal() {
  echo "$1"
  exit 1
}

warn() {
  echo "$1"
}

# Find a source mirror near you which supports rsync on
# https://launchpad.net/ubuntu/+cdmirrors
# rsync://<iso-country-code>.rsync.releases.ubuntu.com/releases should always work
RSYNCSOURCE=rsync://se.rsync.releases.ubuntu.com/releases
#RSYNCSOURCE=rsync://ftp.uninett.no/ubuntu-iso
#RSYNCSOURCE=rsync://ubuntu.uib.no/ubuntu-releases/

# Define where you want the mirror-data to be on your mirror
BASEDIR=/store2/mirror/ubuntu-releases/

if [ ! -d ${BASEDIR} ]; then
  warn "${BASEDIR} does not exist yet, trying to create it..."
  mkdir -p ${BASEDIR} || fatal "Creation of ${BASEDIR} failed."
fi

#rsync -v --progress --stats --recursive --times --links --hard-links \
#  --stats --delete-after \
#  ${RSYNCSOURCE} ${BASEDIR}


rsync -q --recursive --times --links --hard-links \
  --stats --delete-after \
  ${RSYNCSOURCE} ${BASEDIR} &>> /var/log/mirror/ubuntu_releases.log || fatal "Failed to rsync from ${RSYNCSOURCE}."

date -u > ${BASEDIR}/.trace/$(hostname -f)

date &>> /var/log/mirror/ubuntu_releases.log
