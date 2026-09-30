---
name: macos-bash32
description: macOS ships bash 3.2 — associative arrays fail silently and corrupt lookups; never use declare -A in scripts that run on macOS
metadata:
  type: reference
---

macOS ships **bash 3.2.57** (frozen for GPLv3 licensing reasons). `declare -A` / `local -A` requires bash 4.0+.

On bash 3.2 this does **not** fail loudly. The declaration is rejected (`declare: -A: invalid option`), the variable becomes a plain *indexed* array, and indexed subscripts are evaluated as **arithmetic** — so string keys collapse to index `0` and every lookup returns the same wrong value.

Symptoms to recognise:
- `declare: -A: invalid option` / `local: -A: invalid option`
- `value too great for base (error token is "<some-string>")`
- `${!map[@]}` expanding to nothing, so loops over the map silently do nothing

Both failure shapes are easy to miss because the script keeps running and exits 0.

Bash-3.2-safe alternatives:
- Small fixed maps → `case "$key" in ... esac`
- Dedup / last-wins over a list → pipe through `awk '{ seen[$1] = $2 } END { ... }'`

`#!/usr/bin/env bash` does **not** save you — it resolves to `/bin/bash` (3.2) unless a newer bash is earlier on PATH, and bootstrap scripts typically run before Homebrew's bash exists.

Real impact (2026-09-29): two instances of this in the dotfiles repo silently disabled the entire bootstrap phase of `install.sh` on macOS (0 of 9 scripts ran, since ~Dec 2025) and made every package-name lookup resolve to `git-delta`. See the dotfiles project CLAUDE.md Learnings for details.
