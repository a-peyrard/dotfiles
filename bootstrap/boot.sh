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