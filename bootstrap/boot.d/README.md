# Bootstrap Scripts Directory Structure

This directory contains bootstrap scripts that are executed during installation. Scripts are organized in subdirectories based on operating system and distribution.

## Directory Structure

```
boot.d/
├── common/          # Scripts run on all platforms
├── macos/           # macOS-specific scripts (override common/)
├── linux/           # Linux-specific scripts (override common/)
└── linux_centos/    # CentOS/RHEL-specific scripts (override linux/ and common/)
└── linux_ubuntu/    # Ubuntu/Debian-specific scripts (override linux/ and common/)
```

## Override Logic

Scripts are collected in this order (later overrides earlier):
1. `common/` - Base scripts for all platforms
2. `$OS_TYPE/` - OS-specific (macos/ or linux/)
3. `${OS_TYPE}_${DISTRO}/` - Distro-specific (e.g., linux_centos/)

If a script with the same name exists in multiple directories, the most specific one wins.

## File Naming Convention

Scripts use numeric prefixes to control execution order:
- `00-09`: Prerequisites and system checks
- `10-19`: Package installation
- `20-49`: System configuration
- `50-89`: Optional tools and runtimes
- `90-99`: Post-installation tasks

## Viewing Active Scripts

To see which scripts would be executed on your system:

```bash
# Show all scripts that would run
cd bootstrap
./boot.sh --dry-run

# Or manually inspect based on your OS
OS_TYPE="macos"  # or "linux"
DISTRO=""        # or "centos", "ubuntu", "arch"

tree boot.d/common boot.d/$OS_TYPE ${DISTRO:+boot.d/${OS_TYPE}_${DISTRO}}
```

## Creating Platform-Specific Scripts

### Example: Script runs everywhere
Place in `common/10_example.sh`

### Example: macOS-only script
Place in `macos/15_macos_tool.sh`

### Example: Override for CentOS
1. Create `common/20_tool.sh` (base version)
2. Create `linux_centos/20_tool.sh` (CentOS-specific version)
   - On CentOS, only the linux_centos version runs
   - On other Linux, the common version runs
   - On macOS, the common version runs (unless macos/20_tool.sh exists)
