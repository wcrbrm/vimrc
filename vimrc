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
	# read each repository in start.txt either clone or update it
	while read u; do
		export NAME=$(basename -- $u)
		if [[ -d ~/.vim/pack/vendor/start/$NAME ]]; then
			echo $NAME - exists
			cd ~/.vim/pack/vendor/start/$NAME
			git pull
		else 
			echo $NAME - cloning
			git clone --depth=1 $u ~/.vim/pack/vendor/start/$NAME 
		fi

	done<$DIR/start.txt

	# symlink vimrc
	find  ~/.vimrc -exec rm -rf {} \;
	ln -s $DIR/.vimrc ~/.vimrc
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

	# push results to git
	cd $DIR
	git add --all  .
	git commit -m "Update `date`"
	git push origin master
}

[[ "$1" == "read" ]] && { config_read; exit 0; }
[[ "$1" == "write" ]] && { config_write; exit 0; }
usage

