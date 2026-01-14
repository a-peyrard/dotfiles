# dotfiles-bundle

A bundle management system for deploying subsets of dotfiles to different target machines (NAS, dev servers, work machines).

## Features

- **Bundle inheritance**: Define a base bundle and extend it for specific targets
- **Platform targeting**: Specify `linux`, `macos`, or `any` for each bundle
- **Override system**: Public and private (`.private`) file overrides per bundle
- **Smart merging**: Deep merge for TOML/JSON files, full replacement for others
- **Interactive deployment**: rsync preview with confirmation before applying changes

## Quick Start

```bash
# List available bundles
dotfiles-bundle list

# Show what files a bundle includes
dotfiles-bundle show server

# Build a tarball
dotfiles-bundle build server

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

Place override files in the bundle directory:

```
bundles/server/
├── bundle.toml
├── destination.private
├── .gitconfig              # Public override (versioned)
└── .gitconfig.private      # Private override (gitignored)
```

- **TOML/JSON files**: Deep merged with the original
- **Other files**: Fully replaced

Private overrides (`.private` suffix) take precedence over public ones.

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
