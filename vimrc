#!/usr/bin/env bash

# This script is ready for storage of individual vim8 configuration in GIT and applying it
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage() {
	echo "USAGE: ./run.sh read|write"
	echo "  read - reads fresh version from GITHUB and sets up the environment"
	echo "  write - saves current environment to GITHUB"
	exit 1
}

config_read() {
	# read each repository in start.txt
	# if there if a folder	
	# git clone --depth=1 ~/.vim/pack/vendor/start/[repo]
	ls -1 ~/.vim/pack/vendor/start/*/.git/config
}

config_write() {
        # read each repository under ./.vim/pack/vendor/start/
	find $DIR/start.txt -exec rm -rf {} \;
	touch $DIR/start.txt
	for v in $(ls -1 ~/.vim/pack/vendor/start/*/.git/config); do
		export URL=$(cat $v | grep url | sed s/url\ =//g)
		if [[ "$URL" != "" ]]; then
			echo $URL >> $DIR/start.txt
		fi
	done

	cd $DIR
	git add --all  .
	git commit -m "Update `date`"
	# git push origin
}

[[ "$1" == "read" ]] && { config_read; exit 0; }
[[ "$1" == "write" ]] && { config_write; exit 0; }
usage

