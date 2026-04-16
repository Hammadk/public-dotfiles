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

  if [[ -h $target && ($(readlink $target) == $path)]]; then
    echo -e "\x1B[90m$label is symlinked to your dotfiles.\x1B[39m"
  elif [[ -f $target && $(md5 $path) == $(md5 $target) ]]; then
    echo -e "\x1B[32m$label exists and was identical to your dotfile.  Overriding with symlink.\x1B[39m"
    symlink $path $target
  elif [[ -a $target ]]; then
    read -p "\x1B[33m$label exists and differs from your dotfile. Override?  [yn]\x1B[39m" -n 1

    if [[ $REPLY =~ [yY]* ]]; then
      symlink $path $target
    fi
  else
    echo -e "\x1B[32m$label does not exist. Symlinking to dotfile.\x1B[39m"
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
