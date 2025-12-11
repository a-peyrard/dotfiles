# Environment Configuration Directory Structure

This directory contains shell environment files that are sourced during zsh startup. Files are organized in subdirectories based on operating system and distribution.

## Directory Structure

```
.env.d/
├── common/          # Environment files loaded on all platforms
├── macos/           # macOS-specific environment (override common/)
├── linux/           # Linux-specific environment (override common/)
└── linux_centos/    # CentOS/RHEL-specific environment (override linux/ and common/)
└── linux_ubuntu/    # Ubuntu/Debian-specific environment (override linux/ and common/)
```

## Override Logic

Environment files are collected in this order (later overrides earlier):
1. `common/` - Base configuration for all platforms
2. `$OS_TYPE/` - OS-specific (macos/ or linux/)
3. `${OS_TYPE}_${DISTRO}/` - Distro-specific (e.g., linux_centos/)

If a file with the same name exists in multiple directories, the most specific one wins.

## File Naming Convention

Files use numeric prefixes to control load order:
- `00-09`: Critical initialization (completions, shell options)
- `10-89`: Main environment configuration (tools, languages, paths)
- `90-98`: Late-loading plugins (must load after completions)
- `99`:    Must load last (syntax highlighting)

## Viewing Active Environment Files

To see which environment files would be loaded in your shell:

```bash
# Check your current OS and distro
echo "OS_TYPE: $OS_TYPE"
echo "DISTRO: $DISTRO"

# See all environment files that will be sourced
ls ~/.env.d/common/*.env 2>/dev/null
ls ~/.env.d/$OS_TYPE/*.env 2>/dev/null
[ -n "$DISTRO" ] && ls ~/.env.d/${OS_TYPE}_${DISTRO}/*.env 2>/dev/null

# Or use tree to see structure
tree ~/.env.d/common ~/.env.d/$OS_TYPE ${DISTRO:+~/.env.d/${OS_TYPE}_${DISTRO}}
```

## Creating Platform-Specific Environment Files

### Example: Configuration for all platforms
Place in `common/20_tool.env`

### Example: macOS-only paths
Place in `macos/18_gnu.env` (GNU tools only needed on macOS)

### Example: Linux-specific paths
Place in `linux/25_custom_linux.env`

### Example: Override for CentOS
1. Create `common/35_vim.env` (base version with conditional logic)
2. Create `linux_centos/35_vim.env` (CentOS-specific paths)
   - On CentOS, only the linux_centos version loads
   - On other platforms, the common version loads

## Load Order Examples

### On macOS:
1. `common/00_completions.env`
2. `common/01_zsh_options.env`
3. `common/10_autojump.env`
4. `macos/18_gnu.env` (overrides if exists in common/)
5. `common/90_fzf-tab.env`
6. `common/99_syntax_highlighting.env`

### On CentOS:
1. `common/00_completions.env`
2. `common/01_zsh_options.env`
3. `linux/10_custom_linux.env` (if exists, overrides common/)
4. `linux_centos/15_centos_specific.env` (if exists, overrides linux/ and common/)
5. `common/90_fzf-tab.env`
6. `common/99_syntax_highlighting.env`
