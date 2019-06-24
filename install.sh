#!/bin/bash

set -e

if [ ! -f backup_script_private.sh ]; then
	echo "Please create (and make executable) backup_script_private.sh (see backup_script.sh)"
	exit 1
fi

set -x
sudo cp backup_script_private.sh backup_script.sh backup.sh restore.sh /usr/bin
sudo cp backup.service  backup.timer /etc/systemd/system/
set +x
echo "All done. You probably want to test it out by running systemctl start backup.service"
echo "Once that is working, run systemctl enable backup.timer && systemctl start backup.timer"
