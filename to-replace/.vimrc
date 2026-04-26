" Vim-plug for package management
" :PlugInstall

" Dependencies:
" brew install ripgrep, for fast search

call plug#begin('~/.vim/plugged')

Plug 'jiangmiao/auto-pairs'
Plug 'chriskempson/base16-vim'
Plug 'lilydjwg/colorizer'
Plug 'dense-analysis/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'fatih/vim-go'
Plug 'pangloss/vim-javascript'
Plug 'thoughtbot/vim-rspec'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'

" Markdown support
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'

" Git and Github integrations. Rhubarb is needed for :GBrowse
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

" Interact with tmux from vim
Plug 'benmills/vimux'

" Vim-turbux builds on vimux and allows TDD for Rails with single key map
Plug 'jgdavey/vim-turbux'

" Set dark material theme
" https://github.com/material-theme/vsc-material-theme#official-portings
Plug 'kaicataldo/material.vim', { 'branch': 'main' }

" Initialize plugin system
call plug#end()

set nobackup
set nowritebackup
set noswapfile
set laststatus=2           " Always display the status line
set autowrite              " Automatically write before running commands
set clipboard=unnamed      " Share the clipboard with OS
set wildmode=list:longest  " When more than one match, list all matches and complete till longest common string
set nojoinspaces           " Use one space, not two, after punctuation.
set showmatch              " When a bracket is inserted, briefly jump to matching one
set textwidth=80           " Break long strings into multiple lines
set so=15                  " Don't hide buffer after pasting content
let g:netrw_liststyle=3    " Set default style of file explorer
let g:netrw_dirhistmax = 0 " Don't save history of network writes

" Softtabs tabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Color scheme settings.
if has("mac")
  colorscheme material
endif

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Tame searching / moving
set ignorecase
set smartcase
set hlsearch

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Ale config
highlight ALEWarning ctermbg=DarkGray

" Markdown config (preservim/vim-markdown)
let g:vim_markdown_folding_level = 3
let g:vim_markdown_folding_style_pythonic = 1

" Turbux config
if filereadable("dev.yml")
  let g:turbux_command_prefix = ''
  let g:turbux_command_test_unit = 'dev test'
elseif filereadable('Gemfile')
  let g:turbux_command_prefix = 'bundle exec'
endif

" hack to fix broken 'run focused test' since https://github.com/jgdavey/vim-turbux/pull/36
let g:turbux_test_type = ''

" RSpec.vim mappings
noremap <leader>T :call RunCurrentSpecFile()<CR>
noremap <leader>t :call RunNearestSpec()<CR>

nnoremap <C--> <C-o>

" Airline config
if has("mac")
  let g:airline_theme='material'
  let g:airline_powerline_fonts = 1
endif

" Rename current file
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'))
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    exec ':bd ' . old_name
    redraw!
  endif
endfunction

map <leader>, :call RenameFile()<cr>

" Run file if we know how
function! RunFile(filename)
  :w
  :silent !clear
  if match(a:filename, '\.rb$') != -1
    exec ":!ruby " . a:filename
  elseif match(a:filename, '\.py$') != -1
    exec ":!python " . a:filename
  elseif match(a:filename, '\.go$') != -1
    exec ":!go run " . a:filename
  elseif match(a:filename, '\.sh$') != -1
    exec ":!bash " . a:filename
  elseif match(a:filename, '\.tex$') != -1
    exec ":!make "
  elseif match(a:filename, 'makefile$') != -1
    exec ":!make "
  else
    exec ":!echo \"Don't know how to execute: \"" . a:filename
  end
endfunction

map <leader>e :call RunFile(expand("%"))<cr>

" NerdTree Toggle mode
noremap <leader>n :NERDTreeToggle<CR>

" Use ripgrep for :grep
set grepprg=rg\ --vimgrep
nnoremap <leader>g :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Change the default behaviour of the quickfix window so items are opened in a
" new tab unless they are already opened in a tab
set switchbuf+=usetab,newtab

" Toggle - comment, uses Vim-commentary
nmap <C-\> gcc<ESC>
vmap <C-\> gcc<ESC>

" Replace t with tabnew in console
ca t tabnew

" %% gives you the current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>

" Browse open buffers
nmap <leader>b :CtrlPBuffer<CR>
nmap <leader>f :CtrlP<CR>
nnoremap <leader>r :CtrlPTag<CR>

"Have leader D just delete the line
nmap <leader>d "_d

" Make Y behave like other capitals
map Y y$

" Auto-reload changed files
set autoread
au FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
au FocusLost,WinLeave * if &autowrite | silent! wall | endif

" Remove the vertical border since we have the number column
set fillchars+=vert:\│
hi VertSplit ctermfg=Black ctermbg=None
set number
