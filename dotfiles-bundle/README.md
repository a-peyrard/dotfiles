# dotfiles-bundle

A bundle management system for deploying subsets of dotfiles to different target machines (NAS, dev servers, work machines).

## Features

- **Bundle inheritance**: Define a base bundle and extend it for specific targets
- **Platform targeting**: Specify `linux`, `macos`, or `any` for each bundle
- **Override system**: Prepend, append, merge, or replace files per bundle
- **Bundle-only files**: Add files that only exist in specific bundles (`.add` suffix)
- **Nested overrides**: Override files in subdirectories by mirroring the structure
- **Smart merging**: Deep merge for TOML/JSON files
- **Interactive deployment**: rsync preview with confirmation before applying changes

## Quick Start

```bash
# List available bundles
dotfiles-bundle list

# Show what files a bundle includes
dotfiles-bundle show server

# Show all files (verbose mode)
dotfiles-bundle show server -v

# Build a tarball
dotfiles-bundle build server

# Preview deployment (dry-run)
dotfiles-bundle deploy server -n

# Deploy to configured destination
dotfiles-bundle deploy server
```

## How It Works

1. **Bundles** are defined in `bundles/<name>/bundle.toml`
2. Each bundle specifies which files to include/exclude from `links/` and `links-in-depth/`
3. Bundles can extend other bundles using `extends = "base"`
4. **Destinations** are configured per-bundle in `bundles/<name>/destination.private`
5. The `build` command creates a portable tarball with all resolved files
6. The `deploy` command builds and rsyncs to the destination with a dry-run preview

## Bundle Configuration

Create a bundle at `bundles/<name>/bundle.toml`:

```toml
[bundle]
name = "server"
description = "Headless Linux server configuration"
extends = "base"           # Optional: inherit from another bundle
target = "linux"           # "linux", "macos", or "any" (default)

[files]
include = [
    ".config/starship.toml",
    ".env.d/linux/",
]
exclude = [
    ".env.d/common/20_gui-app.env",
]

[runtime]
# Files to copy from $HOME (e.g., plugin directories)
include = [
    ".tmux/plugins/",
    ".zsh/plugins/",
]
exclude = [
    "**/.git/",
]

[packages]
# Packages to install (inherited from base, child bundles can add more)
install = [
    "git",
    "tmux",
    "vim",
    "zsh",
    "fzf",
    "starship",
]
```

### Patterns

- `file.txt` - Exact file match
- `.config/` - Directory and all contents (trailing slash)
- `.bin/*` - Glob pattern
- `**/.git/` - Recursive pattern

### Destination Configuration

Create `bundles/<name>/destination.private` (gitignored):

```toml
target = "user@hostname:~"
ssh_opts = "-p 2222"  # Optional SSH options
```

See `destination.private.example` for a template.

## Override System

Override files allow customizing dotfiles per-bundle. They are placed in the bundle directory with a specific naming pattern.

### Filename Pattern

```
<filename>.<mode>                    # e.g., .zshrc.prepend
<filename>.<mode>.<order>            # e.g., .zshrc.prepend.0
<filename>.<mode>.private            # e.g., .zshrc.prepend.private
<filename>.<mode>.<order>.private    # e.g., .zshrc.prepend.0.private
```

### Override Modes

| Mode | Description |
|------|-------------|
| `prepend` | Add content at the start of the file |
| `append` | Add content at the end of the file |
| `merge` | Deep merge (TOML/JSON files only) |
| `replace` | Full file replacement |
| `add` | Bundle-only file (no base file required) |

### Nested Overrides

Overrides can target files in subdirectories by mirroring the directory structure:

```
bundles/dev-server/
├── bundle.toml
├── .gitconfig.merge                    # Override for .gitconfig
└── .config/
    └── nvim/
        └── init.lua.append             # Override for .config/nvim/init.lua
```

### Bundle-Only Files (add mode)

Use the `add` mode for files that only exist in a specific bundle (no base file in `links/`):

```
bundles/dev-server/
├── .my-special-config.add              # Creates .my-special-config
└── .secrets.add.private                # Private bundle-only file
```

### Directory Additions

Add entire directories by suffixing the directory name with `.add`:

```
bundles/dev-server/
└── .config/
    └── my-tool.add/                    # Creates .config/my-tool/
        ├── config.toml
        └── themes/
            └── dark.toml
```

The `.add` suffix is stripped from the target path. All contents are copied recursively.

### Example Structure

```
bundles/dev-server/
├── bundle.toml
├── destination.private
├── .zshrc.prepend               # Public: added at start of .zshrc
├── .zshrc.prepend.private       # Private: added after public prepend
├── .gitconfig.merge             # Deep merged with base .gitconfig
├── .tmux.conf.replace.private   # Fully replaces .tmux.conf (private)
├── .my-bundle-config.add        # Bundle-only file
└── .config/
    ├── nvim/
    │   └── init.lua.append      # Appended to .config/nvim/init.lua
    └── my-tool.add/             # Bundle-only directory
        └── settings.toml
```

### Ordering

When multiple overrides of the same mode exist, use numeric suffixes to control order:

```
.zshrc.prepend.0           # Applied first
.zshrc.prepend.1           # Applied second
.zshrc.prepend.2.private   # Applied third (private)
```

### Application Order

1. **Prepend** overrides (sorted by order, then public before private)
2. **Merge** overrides (for TOML/JSON only)
3. **Replace** overrides (last one wins)
4. **Append** overrides (sorted by order, then public before private)
5. **Add** files are copied directly (no base file needed)

### Merge Behavior

- **TOML/JSON files with `merge` mode**: Keys are deep merged recursively
- **Other files**: Use `prepend`, `append`, or `replace` modes

## Development

### Prerequisites

- Python 3.11+
- [uv](https://github.com/astral-sh/uv) for dependency management

### Running Tests

```bash
cd dotfiles-bundle
uv run pytest tests/ -v
```

### Type Checking

```bash
cd dotfiles-bundle
uv run pyright src/dotfiles-bundle
```

### Project Structure

```
dotfiles-bundle/
├── pyproject.toml          # Python project configuration
├── src/
│   └── dotfiles-bundle     # Main script (symlinked from links/.bin/)
└── tests/
    └── test_dotfiles_bundle.py
```

The script is symlinked to `links/.bin/dotfiles-bundle` so it's available in PATH after dotfiles installation.
