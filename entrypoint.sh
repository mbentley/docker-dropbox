#!/bin/bash

set -e

DBOX_USERNAME="${DBOX_USERNAME:-default}"
DBOX_GROUP="${DBOX_GROUP:-${DBOX_USERNAME}}"
DBOX_UID="${DBOX_UID:-1000}"
DBOX_GID="${DBOX_GID:-${DBOX_UID}}"

trap 'stop_dropbox' SIGTERM

stop_dropbox() {
  gosu "${DBOX_USERNAME}" dropbox.py stop
  exit 0
}

# check to see if group exists; if not, create it
if grep -q -E "^${DBOX_GROUP}:" /etc/group > /dev/null 2>&1
then
  echo "INFO: Group exists; skipping creation"
else
  echo "INFO: Group doesn't exist; creating..."
  # create the group
  groupadd -g "${DBOX_GID}" "${DBOX_GROUP}"
fi

# check to see if user exists; if not, create it
if id -u "${DBOX_USERNAME}" > /dev/null 2>&1
then
  echo "INFO: User exists; skipping creation"
else
  echo "INFO: User doesn't exist; creating..."
  # create the user
  useradd -u "${DBOX_UID}" -g "${DBOX_GID}" -d "/home/${DBOX_USERNAME}" "${DBOX_USERNAME}" -s /bin/bash
fi

# create directories if needed
for DIR in "/home/${DBOX_USERNAME}" "/home/${DBOX_USERNAME}/Dropbox" "/home/${DBOX_USERNAME}/.dropbox"
do
  if [ ! -d "${DIR}" ]
  then
    echo "INFO: Creating '${DIR}'"
    mkdir "${DIR}"
  else
    echo "INFO: ${DIR} already exists"
  fi
done

# create symlink to home directory
echo "INFO: Creating symlink from '/opt/dropbox/.dropbox-dist' to '/home/${DBOX_USERNAME}/.dropbox-dist'"
ln -sf "/opt/dropbox/.dropbox-dist" "/home/${DBOX_USERNAME}/.dropbox-dist"

# change ownership of directories
chown -R "${DBOX_USERNAME}:${DBOX_GROUP}" "/home/${DBOX_USERNAME}"

# check to see if an existing PID file exists; remove if so
if [ -f "/home/${DBOX_USERNAME}/.dropbox/dropbox.pid" ]
then
  echo "INFO: Existing PID file found; removing"
  rm "/home/${DBOX_USERNAME}/.dropbox/dropbox.pid"
fi

# start dropbox
if [ "${*}" = "start" ]
then
  echo "INFO: Running Dropbox as ${DBOX_USERNAME}:${DBOX_GROUP} (${DBOX_UID}:${DBOX_GID})"
  gosu "${DBOX_USERNAME}" /tini -s -- /home/"${DBOX_USERNAME}"/.dropbox-dist/dropboxd
else
  gosu "${DBOX_USERNAME}" "${@}"
fi

# while loop because dropbox is really fucking stupid about how they run their app
while [ "$(pidof dropbox)" ]
do
  sleep 5
done

exit 1
