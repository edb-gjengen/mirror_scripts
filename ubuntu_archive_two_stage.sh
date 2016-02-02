#/bin/dash

fatal() {
  echo "$1"
  exit 1
}

warn() {
  echo "$1"
}

# Find a source mirror near you which supports rsync on
# https://launchpad.net/ubuntu/+archivemirrors
# rsync://<iso-country-code>.rsync.archive.ubuntu.com/ubuntu should always work
RSYNCSOURCE=rsync://no.archive.ubuntu.com/ubuntu/
#RSYNCSOURCE=rsync://ubuntu.uib.no/ubuntu-archive/
#RSYNCSOURCE=rsync://ftp.uninett.no/ubuntu/

# Define where you want the mirror-data to be on your mirror
BASEDIR=/store/mirror/ubuntu/archive/

if [ ! -d ${BASEDIR} ]; then
  warn "${BASEDIR} does not exist yet, trying to create it..."
  mkdir -p ${BASEDIR} || fatal "Creation of ${BASEDIR} failed."
fi

rsync -4 --verbose --recursive --times --links --hard-links \
  --stats --chmod=a+rx \
  --exclude "Packages*" --exclude "Sources*" \
  --exclude "Release*" \
  ${RSYNCSOURCE} ${BASEDIR} &>> /opt/scripts/ubuntu_archive_two_stage.log || fatal "First stage of sync failed."

rsync -4 --verbose --recursive --times --links --hard-links \
  --stats --delete --chmod=a+rx --delete-after \
  ${RSYNCSOURCE} ${BASEDIR} &>> /opt/scripts/ubuntu_archive_two_stage.log || fatal "Second stage of sync failed."

date -u > ${BASEDIR}/project/trace/$(hostname -f)

date &>> /opt/scripts/ubuntu_archive_two_stage.log
echo "############################" &>> /opt/scripts/ubuntu_archive_two_stage.log
