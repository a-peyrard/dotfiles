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

boots_already_done=()
while IFS=\n read line
do
	boots_already_done+=($line)
done <<< "$(find $boot_log_dir -type f -exec basename {} \;|perl -pe 's/(.*)\.\d{8}-\d{4}/\1/')"

function containsElement() {
  local e match="$1"
  shift

  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Collect boot scripts from subdirectories with override logic
# Priority: OS-specific > common
collect_boot_scripts() {
  local -A script_paths  # Associative array: filename -> full_path

  # First, collect from common/
  if [ -d "${boot_scripts_dir}/common" ]; then
    while IFS= read -r script; do
      local filename=$(basename "$script")
      script_paths["$filename"]="$script"
    done < <(find "${boot_scripts_dir}/common" -maxdepth 1 -name "*.sh" -type f)
  fi

  # Then, collect from OS-specific directory (override common if same name)
  local os_dir=""
  if [ "$OS_TYPE" = "macos" ]; then
    os_dir="${boot_scripts_dir}/macos"
  elif [ "$OS_TYPE" = "linux" ]; then
    os_dir="${boot_scripts_dir}/linux"

    # Also check for distro-specific (e.g., linux_centos/)
    if [ -n "$DISTRO" ] && [ -d "${boot_scripts_dir}/linux_${DISTRO}" ]; then
      while IFS= read -r script; do
        local filename=$(basename "$script")
        script_paths["$filename"]="$script"
      done < <(find "${boot_scripts_dir}/linux_${DISTRO}" -maxdepth 1 -name "*.sh" -type f)
    fi
  fi

  if [ -n "$os_dir" ] && [ -d "$os_dir" ]; then
    while IFS= read -r script; do
      local filename=$(basename "$script")
      script_paths["$filename"]="$script"  # Override if exists
    done < <(find "$os_dir" -maxdepth 1 -name "*.sh" -type f)
  fi

  # Output sorted by filename (numeric ordering works naturally)
  for filename in $(echo "${!script_paths[@]}" | tr ' ' '\n' | sort); do
    echo "${script_paths[$filename]}"
  done
}

for boot_script in $(collect_boot_scripts); do
	if containsElement "$(basename ${boot_script})" "${boots_already_done[@]}"; then
		echo " ⏩  skip ${bold}${boot_script}${normal}, already executed"
	else
		if [[ ${dry_run} == 1 ]]; then
			echo " ✨   (DRY RUN) running ${bold}${boot_script}${normal}"
			bash $boot_script --dry-run
		else
			echo " ✨  running ${bold}${boot_script}${normal}"
			bash $boot_script
			touch $boot_log_dir/$(basename $boot_script).$(date +%Y%m%d-%H%M)
		fi
	fi
done