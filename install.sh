#!/bin/bash

set -e

sudo cp backup_script_private.sh /usr/bin
sudo cp backup_script.sh /usr/bin
sudo cp backup.sh /usr/bin
sudo cp restore.sh /usr/bin
sudo cp backup.service /etc/systemd/system/
sudo cp backup.timer /etc/systemd/system/
