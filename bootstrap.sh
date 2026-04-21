#!/bin/bash
# Links everything in dotFiles/home/ to ~/, does sanity checks. Run bash
# bootstrap.sh, and it will create symlinks for files in the dotFiles/home folder
# unless they exist in ~/ already.

symlink() {
  ln -nsf $1 $2
}

link_target() {
  local path=$1
  local target=$2
  local label=$3

  if [[ -h $target && ($(readlink $target) == $path) ]]; then
    printf '\033[90m%s is symlinked to your dotfiles.\033[39m\n' "$label"
  elif [[ -f $target && $(md5 $path) == $(md5 $target) ]]; then
    printf '\033[32m%s exists and was identical to your dotfile. Overriding with symlink.\033[39m\n' "$label"
    symlink $path $target
  elif [[ -a $target ]]; then
    printf '\033[33m%s exists and differs from your dotfile. Override? [yn]\033[39m ' "$label"
    read -n 1 REPLY
    printf '\n'

    if [[ $REPLY =~ [yY]* ]]; then
      symlink $path $target
    fi
  else
    printf '\033[32m%s does not exist. Symlinking to dotfile.\033[39m\n' "$label"
    symlink $path $target
  fi
}

# Symlink dotfiles from home/ to ~/
for file in home/.[^.]*; do
  [[ $(basename $file) == ".config" ]] && continue
  path="$(pwd)/$file"
  base=$(basename $file)
  link_target $path "$HOME/$base" "~/$base"
done

# Symlink ~/.config/* subdirectories individually (don't clobber ~/.config)
if [[ -d home/.config ]]; then
  mkdir -p "$HOME/.config"
  for dir in home/.config/*/; do
    [[ -d $dir ]] || continue
    path="$(pwd)/$dir"
    path="${path%/}"  # strip trailing slash
    base=$(basename $dir)
    link_target "$path" "$HOME/.config/$base" "~/.config/$base"
  done
fi
