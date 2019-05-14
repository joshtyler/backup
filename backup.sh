#!/bin/bash

# Simple tool to handle incremental backups

check_folder() {
	if [ ! -d ${1} ]; then
		echo "Folder ${1} does not exist"
		exit 1
	fi
}

trim_trailing_slashes() {
	RESULT=$(echo "$1" | sed 's:/*$::')
	echo "$RESULT"
}

if [ "$#" -ne 3 ]; then
	echo "Usage ${0} [backup/restore] [folder to backup] [backup destination folder] "
	exit 1
fi

ACTION=$1
SOURCE_DIR= trim_trailing_slashes $2
TAR_DIR=$3

check_folder $SOURCE_DIR
check_folder $TAR_DIR

# Pass this function either --create or --extract
do_tar() {
	TARNAME=$(date +"%F_%H%M%S_%N")
	tar ${ACTION} --listed-incremental=${TAR_DIR}/meta.snar --file=${TAR_DIR}/${TARNAME}.tar ${SOURCE_DIR}
}


case $1 in
	"backup"*)
		do_tar "--create"
		;;
	"restore"*)
		do_tar "--extract"
	;;
	*)
		echo "Invalid command"
		exit 1
esac
