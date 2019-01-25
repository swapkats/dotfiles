scriptencoding utf-8
"plug needs this
set nocompatible
filetype off

let mapleader = ","
let maplocalleader = "\\"
map <Leader>h :echo "mapleader is set to ','."<CR>



" set F1 to esc
map <F1> <Esc>
imap <F1> <Esc>

set lcs=tab:\ \ ,eol:$,trail:~,extends:>,precedes:<

" Press F12 to see line endings etc
set nolist
nnoremap <F12> :set list!<CR>


" Don't need a byte order mark in unicode
set nobomb

" Use 2 spaces and no tabs by default
set ts=2  " Tabs are 2 spaces
set bs=2  " Backspace over everything in insert mode
set shiftwidth=2  " Tabs under smart indent
set nocp incsearch

set nobackup

set ruler
set history=5000

call plug#begin()
" Theme sets
Plug 'qualiabyte/vim-colorstepper'
nmap <F6> <Plug>ColorstepPrev
nmap <F7> <Plug>ColorstepNext
nmap <S-F7> <Plug>ColorstepReload
Plug 'tomasr/molokai'
Plug 'w0ng/vim-hybrid'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'NLKNguyen/papercolor-theme'
Plug 'nanotech/jellybeans.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'ajmwagar/vim-deus'
Plug 'romainl/Apprentice'
Plug 'notpratheek/vim-luna'

Plug 'vim-scripts/L9'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --js-completer ' }

Plug 'w0rp/ale'
" let g:ale_fix_on_save = 1

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ale#enabled = 1

Plug 'terryma/vim-multiple-cursors'
let g:multi_cursor_next_key='<C-m>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'epilande/vim-react-snippets'
let g:UltiSnipsExpandTrigger="<C-l>"
let g:UltiSnipsExpandTrigger = "<nop>"
let g:ulti_expand_or_jump_res = 0
function ExpandSnippetOrCarriageReturn()
  let snippet = UltiSnips#ExpandSnippetOrJump()
  if g:ulti_expand_or_jump_res > 0
    return snippet
  else
    return "\<CR>"
  endif
endfunction
inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"

Plug 'elixir-lang/vim-elixir'
Plug 'vim-scripts/nginx.vim'
Plug 'vim-scripts/cocoa.vim'
Plug 'vim-scripts/applescript.vim'
Plug 'vim-scripts/httplog'
Plug 'vim-scripts/ScrollColors'
Plug 'StanAngeloff/php.vim'

Plug 'michaeljsmith/vim-indent-object'
let g:indentobject_meaningful_indentation = ["haml", "sass", "python", "yaml", "markdown", "coffee"]

Plug 'Twinside/vim-syntax-haskell-cabal'
Plug 'lukerandall/haskellmode-vim'

Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'kana/vim-textobj-user'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'vim-scripts/gitignore'
Plug 'kien/ctrlp.vim'
let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules|bower_components|tmp|cache|\.tmp|plugins|platforms|build|ios|_build|deps|priv|public.packs)$',
      \ 'file': '\v\.(exe|so|dll)$',
      \ 'link': 'some_bad_symbolic_links',
      \ }

Plug 'lunaru/vim-less'
Plug 'tpope/vim-haml'
Plug 'juvenn/mustache.vim'
Plug 'tpope/vim-markdown'
Plug 'slim-template/vim-slim'

Plug 'zaiste/VimClojure'
let vimclojure#HighlightBuiltins=1
let vimclojure#ParenRainbow=0

Plug 'elzr/vim-json'
Plug 'alfredodeza/jacinto.vim'

Plug 'ap/vim-css-color'
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
let g:used_javascript_libs = 'react'
Plug 'mxw/vim-jsx'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
let g:prettier#autoformat = 0
let g:prettier#exec_cmd_async = 1
let g:prettier#quickfix_enabled = 0
let g:prettier#quickfix_auto_focus = 0
let g:prettier#config#print_width = 140
let g:prettier#config#single_quote = 'true'
let g:prettier#config#trailing_comma = 'all'
let g:prettier#config#bracket_spacing = 'true'

call plug#end()




au BufNewFile,BufReadPost *.coffee setl shiftwidth=2 tabstop=2 softtabstop=2 expandtab
autocmd BufNewFile,BufRead *.json call jacinto#syntax()
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable
au BufNewFile,BufReadPost *.coffee setl tabstop=2 softtabstop=2 shiftwidth=2 expandtab



au BufNewFile,BufReadPost *.json setl filetype=json
au BufNewFile,BufReadPost *.rake setl filetype=ruby shiftwidth=2 tabstop=2 softtabstop=2 expandtab
au BufNewFile,BufReadPost *.es6 setl filetype=javascript
au BufNewFile,BufReadPost *.jade setl shiftwidth=2 tabstop=2 softtabstop=2 expandtab
au BufNewFile,BufReadPost *.html setl expandtab foldmethod=indent
au BufNewFile,BufReadPost *.slim setl filetype=slim shiftwidth=2 tabstop=2 softtabstop=2 expandtab foldmethod=indent
au BufNewFile,BufReadPost *.html.erb setl filetype=html.eruby shiftwidth=2 tabstop=2 softtabstop=2 expandtab foldmethod=indent
au BufNewFile,BufReadPost *.ex  setl filetype=elixir shiftwidth=2 tabstop=2 softtabstop=2 expandtab
au BufNewFile,BufReadPost *.exs setl filetype=elixir shiftwidth=2 tabstop=2 softtabstop=2 expandtab
au BufNewFile,BufReadPost *.phtml setl filetype=php shiftwidth=2 tabstop=2 softtabstop=2 expandtab ff=dos ffs=dos


autocmd FileType java set tw=80 ai sw=4 sts=4 et
autocmd FileType ruby,eruby,yaml set tw=80 ai sw=2 sts=2 et
autocmd User Rails set tabstop=2 shiftwidth=2 softtabstop=2 expandtab

"Make git commit nicer
autocmd FileType gitcommit set tw=68 spell


au BufEnter *.hs compiler ghc

let g:ghc = "/usr/local/bin/ghc"
let g:haddock_browser = "open"


filetype plugin indent on
syntax enable
syntax on

set scrolloff=5
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

map Y y$
vnoremap <leader>yo "*y
nnoremap <leader>po "*p

noremap <silent><Leader>/ :nohls<CR>

" better ESC
inoremap jk <Esc>

nmap ; :

set autoread
set backspace=indent,eol,start
set binary
set cinoptions=:0,(s,u0,U1,g0,t0
set completeopt=menuone,preview
set encoding=utf-8
set hidden
set history=1000
set incsearch
set laststatus=2

" Don't redraw while executing macros
set nolazyredraw

" Disable the macvim toolbar
set guioptions-=T

set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set showbreak=↳

set notimeout
set ttimeout
set ttimeoutlen=10

set noeol
set numberwidth=4
set number
set ruler
set showcmd

set exrc
set secure
set matchtime=2

set completeopt=longest,menuone,preview

" White characters {{{
set autoindent
set tabstop=2
set softtabstop=2
set textwidth=80
set shiftwidth=2
set expandtab
set wrap
set formatoptions=qrn1

set novisualbell

set wildignore=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,.DS_Store,*.aux,*.out,*.toc
set wildmenu

"set dictionary=/usr/share/dict/words
augroup cline
  au!
  au WinLeave * set nocursorline
  au WinEnter * set nocursorline
  au InsertEnter * set nocursorline
  au InsertLeave * set nocursorline
augroup END
" Only shown when not in insert mode so I don't go insane.
"augroup trailing
"  au!
"  au InsertEnter * :set listchars-=trail:⌴
"  au InsertLeave * :set listchars+=trail:⌴
"augroup END

" Remove trailing whitespaces when saving
:command SS %s/\s\+$//e

"nnoremap / /\v
"vnoremap / /\v

set smartcase
set showmatch
set hlsearch

" clear search matching
noremap <leader><space> :noh<cr>:call clearmatches()<cr>

" Don't jump when using * for search
nnoremap * *<c-o>

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz

" Open a Quickfix window for the last search.
nnoremap <silent> <leader>? :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

" Highlight word {{{

nnoremap <silent> <leader>hh :execute 'match InterestingWord1 /\<<c-r><c-w>\>/'<cr>
nnoremap <silent> <leader>h1 :execute 'match InterestingWord1 /\<<c-r><c-w>\>/'<cr>
nnoremap <silent> <leader>h2 :execute '2match InterestingWord2 /\<<c-r><c-w>\>/'<cr>
nnoremap <silent> <leader>h3 :execute '3match InterestingWord3 /\<<c-r><c-w>\>/'<cr>


" Begining & End of line in Normal mode
noremap H ^
noremap L g_

" more natural movement with wrap on
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" Easy splitted window navigation
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l

" Easy buffer navigation
noremap <leader>bp :bprevious<cr>
noremap <leader>bn :bnext<cr>

" Splits ,v and ,h to open new splits (vertical and horizontal)
nnoremap <leader>v <C-w>v<C-w>l
nnoremap <leader>s <C-w>s<C-w>j

" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" Bubbling lines
nmap <C-Up> [e
nmap <C-Down> ]e
vmap <C-Up> [egv
vmap <C-Down> ]egv


set foldlevelstart=1
set foldmethod=syntax

" Space to toggle folds.
nnoremap <space> za
vnoremap <space> za
nnoremap z0 :set foldlevel=0<CR>
nnoremap z1 :set foldlevel=1<CR>
nnoremap z2 :set foldlevel=2<CR>
nnoremap z3 :set foldlevel=3<CR>
nnoremap z4 :set foldlevel=4<CR>
nnoremap z5 :set foldlevel=5<CR>
nnoremap z6 :set foldlevel=6<CR>
nnoremap z7 :set foldlevel=7<CR>
nnoremap z8 :set foldlevel=8<CR>
nnoremap z9 :set foldlevel=99<CR>

" Make zO recursively open whatever top level fold we're in, no matter where the
" cursor happens to be.
nnoremap zO zCzO

" Use ,z to "focus" the current fold.
nnoremap <leader>z zMzvzz

function! MyFoldText() " {{{
  let line = getline(v:foldstart)

  let nucolwidth = &fdc + &number * &numberwidth
  let windowwidth = winwidth(0) - nucolwidth - 3
  let foldedlinecount = v:foldend - v:foldstart

  " expand tabs into spaces
  let onetab = strpart('          ', 0, &tabstop)
  let line = substitute(line, '\t', onetab, 'g')

  let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
  let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
  return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction " }}}
set foldtext=MyFoldText()


set ofu=syntaxcomplete#Complete
let g:rubycomplete_buffer_loading = 0
let g:rubycomplete_classes_in_global = 1

" showmarks
let g:showmarks_enable = 1
hi! link ShowMarksHLl LineNr
hi! link ShowMarksHLu LineNr
hi! link ShowMarksHLo LineNr
hi! link ShowMarksHLm LineNr

augroup ft_vim
  au!

  au FileType vim setlocal foldmethod=marker
  au FileType help setlocal textwidth=78
  au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END


" Shortcut for [] motion
onoremap ir i[
onoremap ar a[
vnoremap ir i[
vnoremap ar a[

" }}}

" Buffer Handling {{{
" Visit http://vim.wikia.com/wiki/Deleting_a_buffer_without_closing_the_window
" to learn more about :Bclose

" Delete buffer while keeping window layout (don't close buffer's windows).
" Version 2008-11-18 from http://vim.wikia.com/wiki/VimTip165
if v:version < 700 || exists('loaded_bclose') || &cp
  finish
endif
let loaded_bclose = 1
if !exists('bclose_multiple')
  let bclose_multiple = 1
endif

" Display an error message.
function! s:Warn(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl NONE
endfunction

" Command ':Bclose' executes ':bd' to delete buffer in current window.
" The window will show the alternate buffer (Ctrl-^) if it exists,
" or the previous buffer (:bp), or a blank buffer if no previous.
" Command ':Bclose!' is the same, but executes ':bd!' (discard changes).
" An optional argument can specify which buffer to close (name or number).
function! s:Bclose(bang, buffer)
  if empty(a:buffer)
    let btarget = bufnr('%')
  elseif a:buffer =~ '^\d\+$'
    let btarget = bufnr(str2nr(a:buffer))
  else
    let btarget = bufnr(a:buffer)
  endif
  if btarget < 0
    call s:Warn('No matching buffer for '.a:buffer)
    return
  endif
  if empty(a:bang) && getbufvar(btarget, '&modified')
    call s:Warn('No write since last change for buffer '.btarget.' (use :Bclose!)')
    return
  endif
  " Numbers of windows that view target buffer which we will delete.
  let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == btarget')
  if !g:bclose_multiple && len(wnums) > 1
    call s:Warn('Buffer is in multiple windows (use ":let bclose_multiple=1")')
    return
  endif
  let wcurrent = winnr()
  for w in wnums
    execute w.'wincmd w'
    let prevbuf = bufnr('#')
    if prevbuf > 0 && buflisted(prevbuf) && prevbuf != w
      buffer #
    else
      bprevious
    endif
    if btarget == bufnr('%')
      " Numbers of listed buffers which are not the target to be deleted.
      let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != btarget')
      " Listed, not target, and not displayed.
      let bhidden = filter(copy(blisted), 'bufwinnr(v:val) < 0')
      " Take the first buffer, if any (could be more intelligent).
      let bjump = (bhidden + blisted + [-1])[0]
      if bjump > 0
        execute 'buffer '.bjump
      else
        execute 'enew'.a:bang
      endif
    endif
  endfor
  execute 'bdelete'.a:bang.' '.btarget
  execute wcurrent.'wincmd w'
endfunction
command! -bang -complete=buffer -nargs=? Bclose call s:Bclose('<bang>', '<args>')
nnoremap <silent> <Leader>bd :Bclose<CR>

"}}}


let g:arrow_keys_are_enabled = 1

function! NoArrowsKeysToggle() " {{{
  if g:arrow_keys_are_enabled == 1
    let g:arrow_keys_are_enabled = 0
    noremap <left> <nop>
    noremap <up> <nop>
    noremap <down> <nop>
    noremap <right> <nop>
  else
    let g:arrow_keys_are_enabled = 1
    noremap <left> h
    noremap <up> k
    noremap <down> j
    noremap <right> l
  endif
endfunction " }}}

nmap <F8> :call NoArrowsKeysToggle()<CR>
"call NoArrowsKeysToggle()


autocmd InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
autocmd InsertLeave * let &l:foldmethod=w:last_fdm

set viminfo='10,\"100,:20,%,n~/.viminfo
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

"Show trailing whitespace
match ErrorMsg '\s\+$'
set incsearch

nnoremap <C-v> :set invpaste paste?<CR>
set pastetoggle=<C-v>
set showmode
nnoremap <silent> <M-Right> :bn<CR>
nnoremap <silent> <M-Left> :bp<CR>
nnoremap <silent> <C-Right> :bn<CR>
nnoremap <silent> <C-Left> :bp<CR>
nnoremap <silent> <C-d> :bd<CR>

highlight clear SpellBad
highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline

set modelines=5
set pastetoggle=<C-v>

set termguicolors
set t_Co=256
set background=dark
colorscheme apprentice
let g:airline_theme='hybridline'


hi TermCursor    gui=reverse   guifg=#ffffff
hi TermCursorNC  gui=reverse   guifg=#ffffff
hi ParenMatch    gui=underline guibg=#343941
hi Folded        gui=NONE cterm=NONE ctermbg=234  ctermfg=242  guibg=#444444 guifg=#acacac
hi ALEWarning    guibg=#916364


source ~/.vimrc.local
