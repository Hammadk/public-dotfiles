This is a copy of Hammad's public dotfiles. Running `bootstrap.sh` symlinks
files from this repo into `$HOME`.

Private config lives in a separate private repo. The public dotfiles conditionally load private overrides
(e.g. `~/.bashrc.private`, `~/.gitconfig.private`) when they exist.

### Usage:

``` sh
cd ~
git clone https://github.com/Hammadk/public-dotfiles.git
cd public-dotfiles
bash bootstrap.sh
```

### Layout:

- `to-replace/<name>` → symlinked to `~/<name>` (atomic; prompts on conflict).
- `to-merge/<name>/*` → children symlinked into a destination mapped in `bootstrap.sh`'s `MERGE_DIRS` (non-destructive; leaves siblings alone).
- `ALIASES` in `bootstrap.sh` → one repo file → one `$HOME` path.

Shell requirements:
``` sh
# Install OhmyZsh: https://github.com/ohmyzsh/ohmyzsh

zsh-autosuggestions      # Load this first (Ghost text)
zsh-autocomplete         # Load this second (The menu)
zsh-syntax-highlighting
```

Mac Requirement:

``` sh
brew install tmux
brew install reattach-to-user-namespace # needed for Tmux

# Dependency for AG
brew install the_silver_searcher
```

Mac nice-to-haves:
```
1. Install Terminal themes in dotfiles/themes
2. Install Fonts from dotfiles/fonts
```

Ghostty font (matches `to-merge/ghostty/config`):
``` sh
brew install --cask font-jetbrains-mono-nerd-font
```

Vim installation:
```
:PlugInstall
```

Vscode installation:
```
1. Copy vscode/public-keybindings.json
2. Copy vscode/public-user-settings.json
```

Mac settings:
```
Keyboard:
* Key repeat rate: fastest
* Delay until repeat: Slowest
* Modifer: Capslock -> No action
* Shortcuts: Cmd + shift + 1 -> GPT
* Shortcuts: Cmd + shift + 2 -> Code Editor
* Shortcuts: Cmd + shift + 3 -> Notes
* Disable default Cmd + shift + 3 -> screenshot shortcut
* ctrl + space -> Ghostty
```

Font installation for powerline:
```
You need to get fonts modified for powerline. Ones that are compatible with
vim-airline:

1. git clone https://github.com/Znuff/consolas-powerline.git
2. Install all fonts.
3. Configure your Terminal or iTerm2 to use the installed Powerline font. iTerm2 -> Preferences -> Profiles -> Text
```
