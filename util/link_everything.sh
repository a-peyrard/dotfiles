#! /usr/bin/env bash
#
# For all files in source directory, create a sym link in the destination 
# directory. It will search for files in depth

function usage() {
	echo "link_everything.sh [src] [dest]"
}

function link_file() {
	local src="$1"
	local file="$2"
	local base_dest="$3"
	local force="$4"
	local verbose="$5"
	local dry_mode="$6"

	options="-sf"
	if [[ $force ]]; then
		options="-sfn"
	fi

	prefix=${src//\//\\/}
	relative_dest=$(sed "s/$prefix//" <<< $file)
	absolute_dest=$(echo "$base_dest$relative_dest")

	log_prefix=""
	if [[ $dry_mode == 1 ]]; then
		log_prefix="(DRY RUN) "
	fi
	[[ $verbose == 1 || $dry_mode == 1 ]] && echo "${log_prefix}-> create a sym link for $file into $absolute_dest"
	if [[ $dry_mode == 0 ]]; then
		base_dir=$(dirname $absolute_dest)
		[[ ! -a $base_dir ]] && mkdir -p $base_dir
		ln $options $file $absolute_dest
	fi
}

# analyze command line
force=0
verbose=0
inside=0
dry_mode=0

OPTIND=1
while getopts ":fvid" option; do
	case $option in
		f ) force=1; ;;
		v ) verbose=1; ;;
		i ) inside=1; ;;
		d ) dry_mode=1; ;;
		* ) usage; exit -1 ;;
	esac
done

shift $(( OPTIND - 1 ))
src=$1
dest=$2

if [[ -z "$src" || -z "$dest" ]]; then
	usage;
	exit -1;
fi

[[ $verbose ]] && echo "==> link all files from $src to $dest (options: force=$force, inside=$inside)"

option="-maxdepth 1"
if [[ $inside -eq 1 ]]; then
	option="-type f"
fi

# do the links
files=$(find $src $option)
for file in $files; do
	link_file $src $file $dest $force $verbose $dry_mode
done

