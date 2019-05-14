#!/bin/bash

# Simple tool to restore incremental backups made with backup.sh

check_folder_exists() {
	if [ ! -d ${1} ]; then
		echo "Folder ${1} does not exist"
		exit 1
	fi
}

check_folder_is_not_empty() {
	if [ ! "$(ls -A ${1})" ]; then
		echo "Folder ${1} is empty"
		exit 1
	fi
}

check_folder_does_not_exist() {
	if [ -d ${1} ]; then
		echo "Folder ${1} already exists"
		exit 1
	fi
}

trim_trailing_slashes() {
	RESULT=$(echo "$1" | sed 's:/*$::')
	echo "$RESULT"
}

if [ "$#" -ne 2 ]; then
	echo "Usage ${0} [backup output folder]  [output folder]"
	exit 1
fi

TAR_DIR=$(trim_trailing_slashes $1)
OUT_DIR=$(trim_trailing_slashes $2)

check_folder_exists $TAR_DIR
check_folder_is_not_empty $TAR_DIR
check_folder_does_not_exist $OUT_DIR
mkdir ${OUT_DIR}

# Bash will expand these in alphabetical order, so we are safe with our timestamp scheme
# Match any type of tar archive, but not any other files (metafiles)
for tarfile in ${TAR_DIR}/*.tar* ; do
	echo "Extracting $tarfile"
	tar --extract --listed-incremental=/dev/null --file=${tarfile} --directory=${OUT_DIR}
done
