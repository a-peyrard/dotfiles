#!/usr/bin/env bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities (formatting variables, etc.)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../util/common.sh"

boot_log_dir="$HOME/.boot_log"
boot_scripts_dir="$(dirname $0)/boot.d"

dry_run=0

# extract parameters
while test $# -gt 0
do
	case "$1" in
		--dry-run) dry_run=1
			;;
	esac
	shift
done

# Source OS detection utility
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../util/detect_os.sh"

if [ ! -d "$boot_log_dir" ]; then
	mkdir "$boot_log_dir"
fi

# Compute md5 checksum portably (macOS vs Linux)
compute_md5() {
  if command -v md5sum &>/dev/null; then
    md5sum "$1" | awk '{print $1}'
  else
    md5 -q "$1"
  fi
}

# Check if a boot script needs to run by comparing its md5 to the stored marker
needs_run() {
  local script="$1"
  local marker_file="$boot_log_dir/$(basename "$script").md5"
  if [ ! -f "$marker_file" ]; then
    return 0  # No marker, needs to run
  fi
  local stored_md5
  stored_md5=$(cat "$marker_file")
  local current_md5
  current_md5=$(compute_md5 "$script")
  [ "$stored_md5" != "$current_md5" ]
}

# Record the md5 of a script after successful execution
record_run() {
  local script="$1"
  compute_md5 "$script" > "$boot_log_dir/$(basename "$script").md5"
}

# Collect boot scripts from subdirectories with override logic
# Priority: OS-specific > common
#
# NOTE: macOS ships bash 3.2, which has no associative arrays. Dedup by
# filename is done with awk instead.
collect_boot_scripts() {
  local os_dir=""
  local distro_dir=""

  if [ "$OS_TYPE" = "macos" ]; then
    os_dir="${boot_scripts_dir}/macos"
  elif [ "$OS_TYPE" = "linux" ]; then
    os_dir="${boot_scripts_dir}/linux"

    # Also check for distro-specific (e.g., linux_centos/)
    if [ -n "$DISTRO" ] && [ -d "${boot_scripts_dir}/linux_${DISTRO}" ]; then
      distro_dir="${boot_scripts_dir}/linux_${DISTRO}"
    fi
  fi

  # Emit candidates in increasing priority order, keep the last path seen
  # per filename, then sort by filename (numeric prefixes order naturally).
  {
    [ -d "${boot_scripts_dir}/common" ] && find "${boot_scripts_dir}/common" -maxdepth 1 -name "*.sh" -type f
    [ -n "$distro_dir" ] && find "$distro_dir" -maxdepth 1 -name "*.sh" -type f
    [ -n "$os_dir" ] && [ -d "$os_dir" ] && find "$os_dir" -maxdepth 1 -name "*.sh" -type f
  } | awk -F/ '{ print $NF "\t" $0 }' \
    | awk -F'\t' '{ seen[$1] = $2 } END { for (f in seen) print f "\t" seen[f] }' \
    | sort \
    | cut -f2-
}

for boot_script in $(collect_boot_scripts); do
	if needs_run "$boot_script"; then
		if [[ ${dry_run} == 1 ]]; then
			echo " ✨   (DRY RUN) running ${bold}${boot_script}${normal}"
			bash $boot_script --dry-run
		else
			echo " ✨  running ${bold}${boot_script}${normal}"
			bash $boot_script
			record_run "$boot_script"
		fi
	else
		echo " ⏩  skip ${bold}${boot_script}${normal}, already executed"
	fi
done