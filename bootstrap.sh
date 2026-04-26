#!/bin/bash
# Bootstrap public dotfiles into $HOME. Works on macOS and Linux.
#
# Layout:
#   to-replace/        Mirrors $HOME. Each top-level entry is symlinked to
#                      $HOME/<name>, prompting before overwriting differing
#                      content.
#   to-merge/<name>/   Children are symlinked into a shared destination under
#                      $HOME (mapped in MERGE_DIRS). Existing siblings at the
#                      destination are left alone.
#   ALIASES            One repo file → one $HOME path (file fan-out).
#
# Stale symlinks pointing into this repo are silently repointed, so it's safe
# to rerun after moving files around in the repo.
#
# Run: bash bootstrap.sh

# --- Configuration ----------------------------------------------------------

# "<dir under to-merge/> = <destination relative to $HOME>"
MERGE_DIRS=(
  "ghostty=.config/ghostty"
)

# "<repo-relative source> <destination relative to $HOME>"
ALIASES=()

# --- Helpers ----------------------------------------------------------------

REPO=$(cd "$(dirname "$0")" && pwd)
symlink() { ln -nsf "$1" "$2"; }

points_into_repo() {
  # $1 = path that is known to be a symlink
  local target
  target=$(readlink "$1")
  [[ "$target" == "$REPO"/* ]]
}

# Replace-mode: prompt on conflict. Used for to-replace/ and ALIASES.
link_replace() {
  local src=$1 dst=$2 label=$3
  if [[ -h $dst && $(readlink "$dst") == "$src" ]]; then
    printf '\033[90m%s already symlinked.\033[39m\n' "$label"
  elif [[ -h $dst ]] && points_into_repo "$dst"; then
    printf '\033[32m%s repointing into repo (%s).\033[39m\n' "$label" "$src"
    symlink "$src" "$dst"
  elif [[ -f $dst && -f $src ]] && cmp -s "$src" "$dst"; then
    printf '\033[32m%s identical → replacing with symlink.\033[39m\n' "$label"
    symlink "$src" "$dst"
  elif [[ -e $dst || -h $dst ]]; then
    printf '\033[33m%s exists and differs. Override? [yn] \033[39m' "$label"
    read -n 1 REPLY; printf '\n'
    [[ $REPLY =~ [yY] ]] && symlink "$src" "$dst"
  else
    mkdir -p "$(dirname "$dst")"
    printf '\033[32m%s missing → symlinking.\033[39m\n' "$label"
    symlink "$src" "$dst"
  fi
}

# Merge-mode: non-destructive. Skip silently if dst exists and isn't ours.
link_merge() {
  local src=$1 dst=$2 label=$3
  if [[ -h $dst && $(readlink "$dst") == "$src" ]]; then
    printf '\033[90m%s already symlinked.\033[39m\n' "$label"
  elif [[ -h $dst ]] && points_into_repo "$dst"; then
    printf '\033[32m%s repointing into repo (%s).\033[39m\n' "$label" "$src"
    symlink "$src" "$dst"
  elif [[ -e $dst || -h $dst ]]; then
    printf '\033[90m%s exists (not ours), skipping.\033[39m\n' "$label"
  else
    mkdir -p "$(dirname "$dst")"
    printf '\033[32m%s missing → symlinking.\033[39m\n' "$label"
    symlink "$src" "$dst"
  fi
}

# --- to-replace/ ------------------------------------------------------------

if [[ -d "$REPO/to-replace" ]]; then
  shopt -s nullglob dotglob
  for entry in "$REPO/to-replace"/*; do
    base=$(basename "$entry")
    link_replace "$entry" "$HOME/$base" "~/$base"
  done
  shopt -u nullglob dotglob
fi

# --- to-merge/ --------------------------------------------------------------

for mapping in "${MERGE_DIRS[@]}"; do
  src_name=${mapping%%=*}
  dest_rel=${mapping#*=}
  src_dir="$REPO/to-merge/$src_name"
  dest_dir="$HOME/$dest_rel"

  [[ -d $src_dir ]] || { printf 'to-merge/%s missing, skipping.\n' "$src_name"; continue; }

  # If the destination is itself a stale symlink into our repo, replace it
  # with a real directory so children can be slotted in individually.
  if [[ -h $dest_dir ]] && points_into_repo "$dest_dir"; then
    printf '\033[32m~/%s was a repo symlink → converting to real dir.\033[39m\n' "$dest_rel"
    rm "$dest_dir"
  fi
  mkdir -p "$dest_dir"

  shopt -s nullglob dotglob
  for entry in "$src_dir"/*; do
    base=$(basename "$entry")
    link_merge "$entry" "$dest_dir/$base" "~/$dest_rel/$base"
  done
  shopt -u nullglob dotglob
done

# --- ALIASES ----------------------------------------------------------------

if (( ${#ALIASES[@]} )); then
  for line in "${ALIASES[@]}"; do
    src_rel=${line%% *}; dst_rel=${line##* }
    link_replace "$REPO/$src_rel" "$HOME/$dst_rel" "~/$dst_rel"
  done
fi
