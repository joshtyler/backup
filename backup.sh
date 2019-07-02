#!/bin/bash

# Simple tool to create incremental backups

check_folder_exists() {
	if [ ! -d ${1} ]; then
		echo "Folder ${1} does not exist"
		exit 1
	fi
}

trim_trailing_slashes() {
	RESULT=$(echo "$1" | sed 's:/*$::')
	echo "$RESULT"
}

if [ "$#" -ne 2 ]; then
	echo "Usage ${0} [folder to backup] [backup output folder]"
	exit 1
fi

SOURCE_DIR=$(trim_trailing_slashes $1)
TAR_DIR=$(trim_trailing_slashes $2)

check_folder_exists $SOURCE_DIR
check_folder_exists $TAR_DIR

TARNAME=$(date +"%F_%H%M%S_%N")
tar --create --bzip2 --listed-incremental=${TAR_DIR}/meta.snar --file=${TAR_DIR}/${TARNAME}.tar.bz2 ${SOURCE_DIR}
