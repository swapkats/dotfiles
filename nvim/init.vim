"
" .vimrc / init.vim
" The following vim/neovim configuration works for both Vim and NeoVim

" ensure vim-plug is installed and then load it
call functions#PlugLoad()
call plug#begin('~/.config/nvim/plugged')

" General {{{
    " Abbreviations
    abbr funciton function
    abbr teh the
    abbr tempalte template
    abbr fitler filter
    abbr cosnt const
    abbr attribtue attribute
    abbr attribuet attribute

    set autoread " detect when a file is changed

    set history=5000 " change history to 1000
    set textwidth=140
    set colorcolumn=+1
    set cursorline

    set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
    set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

    if (has('nvim'))
        " show results of substition as they're happening
        " but don't open a split
        set inccommand=nosplit
    endif

    set backspace=indent,eol,start " make backspace behave in a sane manner
    set clipboard=unnamed

    if has('mouse')
        set mouse=a
    endif

    " Searching
    set ignorecase " case insensitive searching
    set smartcase " case-sensitive if expresson contains a capital letter
    set hlsearch " highlight search results
    set incsearch " set incremental search, like modern browsers
    set nolazyredraw " don't redraw while executing macros

    set magic " Set magic on, for regex

    " error bells
    set noerrorbells
    set visualbell
    set t_vb=
    set tm=500
" }}}

" Appearance {{{
    set number relativenumber " show line numbers
    set wrap " turn on line wrapping
    set wrapmargin=8 " wrap lines when coming within n characters from side
    set linebreak " set soft wrapping
    set showbreak=… " show ellipsis at breaking
    set autoindent " automatically set indent of new line
    set ttyfast " faster redrawing
    set diffopt+=vertical
    set laststatus=2 " show the satus line all the time
    set so=7 " set 7 lines to the cursors - when moving vertical
    set wildmenu " enhanced command line completion
    set hidden " current buffer can be put into background
    set showcmd " show incomplete commands
    set noshowmode " don't show which mode disabled for PowerLine
    set wildmode=list:longest " complete files like a shell
    set scrolloff=3 " lines of text around cursor
    set shell=$SHELL
    set cmdheight=1 " command bar height
    set title " set terminal title
    set showmatch " show matching braces
    set mat=2 " how many tenths of a second to blink

    " Tab control
    set noexpandtab " insert tabs rather than spaces for <Tab>
    set smarttab " tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
    set tabstop=4 " the visible width of tabs
    set softtabstop=4 " edit as if the tabs are 4 characters wide
    set shiftwidth=4 " number of spaces to use for indent and unindent
    set shiftround " round indent to a multiple of 'shiftwidth'

    " code folding settings
    set foldmethod=syntax " fold based on indent
    set foldlevelstart=1
    set foldnestmax=10 " deepest fold is 10 levels
    set foldlevel=1

    " toggle invisible characters
    set nolist
    " set listchars=tab:→\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
    " set showbreak=↪

    set t_Co=256 " Explicitly tell vim that the terminal supports 256 colors
    " switch cursor to line when in insert mode, and block when not
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
    \,sm:block-blinkwait175-blinkoff150-blinkon175

    if &term =~ '256color'
        " disable background color erase
        set t_ut=
    endif

    " enable 24 bit color support if supported
    " if (has('mac') && empty($TMUX) && has("termguicolors"))
        set termguicolors
    " endif

    " highlight conflicts
    match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

    " Load colorschemes
    Plug 'romainl/Apprentice'
    Plug 'altercation/solarized'
    Plug 'altercation/vim-colors-solarized'
    Plug 'joshdick/onedark.vim'
	Plug 'chriskempson/base16-vim'

	let g:netrw_banner = 0
	let g:netrw_liststyle = 3
	let g:netrw_browse_split = 4
	let g:netrw_altv = 1
	let g:netrw_winsize = 25

    " LightLine {{{
		Plug 'ryanoasis/vim-devicons'
        Plug 'itchyny/lightline.vim'
        " Plug 'nicknisi/vim-base16-lightline'
		Plug 'mike-hearn/base16-vim-lightline'
        Plug 'mgee/lightline-bufferline'
        " Plug 'felixjung/vim-base16-lightline'
        set showtabline=2
        let g:lightline = {
        \    'colorscheme': 'base16_default_dark',
        \    'active': {
        \        'left': [ [ 'mode', 'paste' ],
        \                [ 'gitbranch' ],
        \                [ 'readonly', 'filetype', 'filename' ]],
        \        'right': [ [ 'percent' ], [ 'lineinfo' ],
        \                [ 'fileformat', 'fileencoding' ],
        \                [ 'linter_errors', 'linter_warnings' ]]
        \    },
        \    'component_expand': {
        \        'linter': 'LightlineLinter',
        \        'linter_warnings': 'LightlineLinterWarnings',
        \        'linter_errors': 'LightlineLinterErrors',
        \        'linter_ok': 'LightlineLinterOk',
        \        'buffers': 'lightline#bufferline#buffers'
        \    },
        \    'component_type': {
        \        'readonly': 'error',
        \        'linter_warnings': 'warning',
        \        'linter_errors': 'error',
        \        'buffers': 'tabsel',
        \    },
        \    'component_function': {
        \        'fileencoding': 'LightlineFileEncoding',
        \        'filename': 'LightlineFileName',
        \        'fileformat': 'LightlineFileFormat',
        \        'filetype': 'LightlineFileType',
        \        'gitbranch': 'LightlineGitBranch'
        \    },
        \    'tabline': {
        \        'left': [ [ 'buffers' ] ],
        \        'right': [ [ 'close' ] ]
        \    },
        \    'tab': {
        \        'active': [ 'filename', 'modified' ],
        \        'inactive': [ 'filename', 'modified' ],
        \    },
        \    'separator': { 'left': '', 'right': '' },
        \    'subseparator': { 'left': '', 'right': '' }
        \ }

        function! LightlineFileName() abort
            let filename = winwidth(0) > 70 ? expand('%') : expand('%:t')
            if filename =~ 'NERD_tree'
                return ''
            endif
            let modified = &modified ? ' +' : ''
            return fnamemodify(filename, ":~:.") . modified
        endfunction

        function! LightlineFileEncoding()
            " only show the file encoding if it's not 'utf-8'
            return &fileencoding == 'utf-8' ? '' : &fileencoding
        endfunction

        function! LightlineFileFormat()
            " only show the file format if it's not 'unix'
            let format = &fileformat == 'unix' ? '' : &fileformat
            return winwidth(0) > 70 ? format . ' ' . WebDevIconsGetFileFormatSymbol() : ''
        endfunction

        function! LightlineFileType()
            return WebDevIconsGetFileTypeSymbol()
            " return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
        endfunction

        function! LightlineLinter() abort
            let l:counts = ale#statusline#Count(bufnr(''))
            return l:counts.total == 0 ? '' : printf('×%d', l:counts.total)
        endfunction

        function! LightlineLinterWarnings() abort
            let l:counts = ale#statusline#Count(bufnr(''))
            let l:all_errors = l:counts.error + l:counts.style_error
            let l:all_non_errors = l:counts.total - l:all_errors
            return l:counts.total == 0 ? '' : '⚠ ' . printf('%d', all_non_errors)
        endfunction

        function! LightlineLinterErrors() abort
            let l:counts = ale#statusline#Count(bufnr(''))
            let l:all_errors = l:counts.error + l:counts.style_error
            return l:counts.total == 0 ? '' : '✖ ' . printf('%d', all_errors)
        endfunction

        function! LightlineLinterOk() abort
            let l:counts = ale#statusline#Count(bufnr(''))
            return l:counts.total == 0 ? 'OK' : ''
        endfunction

        function! LightlineGitBranch()
            return '' . (exists('*fugitive#head') ? fugitive#head() : '')
        endfunction

        augroup alestatus
            autocmd User ALELint call lightline#update()
        augroup end
    " }}}
" }}}

" General Mappings {{{
    " set a map leader for more key combos
    let mapleader = ','

	" shortcut to save
	nmap <space><space> :w<cr>
	nmap <leader>, :w<cr>
	nmap ;; :
	nmap <leader>h :set hlsearch!<cr>

	" Nerd tree like project explorer
	nmap <leader>k :Vexplore<cr>

        nmap <leader>w <C-w>
        map <leader>q :wincmd c<cr>
        nmap <leader>b :Bdelete<cr>

	nmap <leader>l :set list!<cr>

	nmap <leader><space> :%s/\s\+$<cr>
	nmap <leader><space><space> :%s/\n\{2,}/\r\r/g<cr>


	" Textmate style indentation
	vmap <leader>[ <gv
	vmap <leader>] >gv
	nmap <leader>[ <<
	nmap <leader>] >>

	" switch between current and last buffer
	nmap <leader>. <c-^>


        nmap <Leader>1 <Plug>lightline#bufferline#go(1)
        nmap <Leader>2 <Plug>lightline#bufferline#go(2)
        nmap <Leader>3 <Plug>lightline#bufferline#go(3)
        nmap <Leader>4 <Plug>lightline#bufferline#go(4)
        nmap <Leader>5 <Plug>lightline#bufferline#go(5)
        nmap <Leader>6 <Plug>lightline#bufferline#go(6)
        nmap <Leader>7 <Plug>lightline#bufferline#go(7)
        nmap <Leader>8 <Plug>lightline#bufferline#go(8)
        nmap <Leader>9 <Plug>lightline#bufferline#go(9)
        nmap <Leader>0 <Plug>lightline#bufferline#go


    " remap esc
    inoremap jk <esc>
    inoremap jj <esc>

    " shortcut to play macro from q register
    nmap '' @q


    " set paste toggle
    set pastetoggle=<C-v>

    " set foldlevel
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

    " Space to toggle folds.
    nnoremap <space> za
    vnoremap <space> za
    
    
    " edit gitconfig
    " map <leader>eg :e! ~/.gitconfig<cr>

    " activate spell-checking alternatives
    nmap ;s :set invspell spelllang=en<cr>

    " remove extra whitespace
    " enable . command in visual mode
    vnoremap . :normal .<cr>

	" move among buffers with CTRL
	map <C-j> :bnext<CR>
	map <C-k> :bprev<CR>

    " map <silent> <C-h> :call functions#WinMove('h')<cr>
    " map <silent> <C-j> :call functions#WinMove('j')<cr>
    " map <silent> <C-k> :call functions#WinMove('k')<cr>
    " map <silent> <C-l> :call functions#WinMove('l')<cr>
    " move line mappings
    " ∆ is <A-j> on macOS
    " ˚ is <A-k> on macOS
    nnoremap ∆ :m .+1<cr>==
    nnoremap ˚ :m .-2<cr>==
    inoremap ∆ <Esc>:m .+1<cr>==gi
    inoremap ˚ <Esc>:m .-2<cr>==gi
    vnoremap ∆ :m '>+1<cr>gv=gv
    vnoremap ˚ :m '<-2<cr>gv=gv

    " toggle cursor line
    " nnoremap <leader>i :set cursorline!<cr>

    " scroll the viewport faster
    nnoremap <C-e> 3<C-e>
    nnoremap <C-y> 3<C-y>

    " moving up and down work as you would expect
    nnoremap <silent> j gj
    nnoremap <silent> k gk
    nnoremap <silent> ^ g^
    nnoremap <silent> $ g$

    " inoremap <tab> <c-r>=Smart_TabComplete()<CR>

    " map <leader>s :call SetCustomCommand()<cr>
    let g:silent_custom_command = 0

    " nnoremap <silent> <leader>u :call functions#HtmlUnEscape()<cr>

    set showmode
    nnoremap <silent> <M-Right> :bn<CR>
    nnoremap <silent> <M-Left> :bp<CR>
    nnoremap <silent> <C-Right> :bn<CR>
    nnoremap <silent> <C-Left> :bp<CR>
    nnoremap <silent> <C-d> :bd<CR>

" }}}

" AutoGroups {{{
    " file type specific settings
    augroup configgroup
        autocmd!

        " automatically resize panes on resize
        autocmd VimResized * exe 'normal! \<c-w>='
        autocmd BufWritePost .vimrc,.vimrc.local,init.vim source %
        autocmd BufWritePost .vimrc.local source %
		autocmd InsertLeave * write

        " save all files on focus lost, ignoring warnings about untitled buffers
        autocmd FocusLost * silent! wa

        " make quickfix windows take all the lower section of the screen
        " when there are multiple windows open
        autocmd FileType qf wincmd J
        autocmd FileType qf nmap <buffer> q :q<cr>

		autocmd BufReadPost,BufNewFile *spec.js set filetype=jasmine.javascript syntax=jasmine
		autocmd BufReadPost,BufNewFile *_spec.js set filetype=jasmine.javascript syntax=jasmine
		autocmd BufReadPost,BufNewFile *Spec.js set filetype=jasmine.javascript syntax=jasmine

    augroup END
" }}}

" General Functionality {{{
    " substitute, search, and abbreviate multiple variants of a word
    Plug 'tpope/vim-abolish'

	" Cheat40 is a foldable extensible 40-column cheat sheet that you may open in Vim by pressing <leader>?
    Plug 'lifepillar/vim-cheat40'

    " search inside files using ripgrep. This plugin provides an Ack command.
    Plug 'wincent/ferret'

    " insert or delete brackets, parens, quotes in pair
    Plug 'jiangmiao/auto-pairs'

    " easy commenting motions
    Plug 'tpope/vim-commentary'

    " mappings which are simply short normal mode aliases for commonly used ex commands
    Plug 'tpope/vim-unimpaired'

    " endings for html, xml, etc. - ehances surround
    Plug 'tpope/vim-ragtag'

    " mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
    Plug 'tpope/vim-surround'

    " tmux integration for vim
    Plug 'benmills/vimux'

    " enables repeating other supported plugins with the . command
    Plug 'tpope/vim-repeat'

    " .editorconfig support
    Plug 'editorconfig/editorconfig-vim'

    " asynchronous build and test dispatcher
    Plug 'tpope/vim-dispatch'

    " netrw helper
    Plug 'tpope/vim-vinegar'

    " single/multi line code handler: gS - split one line into multiple, gJ - combine multiple lines into one
    Plug 'AndrewRadev/splitjoin.vim'

    " extended % matching
    Plug 'vim-scripts/matchit.zip'

    " add end, endif, etc. automatically
    Plug 'tpope/vim-endwise', { 'for': [ 'ruby', 'bash', 'zsh', 'sh', 'vim' ]}

    " detect indent style (tabs vs. spaces)
    Plug 'tpope/vim-sleuth'

    " Open selection in carbon.now.sh
    Plug 'kristijanhusak/vim-carbon-now-sh'
    " a simple tool for presenting slides in vim based on text files
    Plug 'sotte/presenting.vim', { 'for': 'markdown' }

    " Close buffers but keep splits
    Plug 'moll/vim-bbye'

    Plug 'terryma/vim-multiple-cursors'
    let g:multi_cursor_next_key='<C-m>'
    let g:multi_cursor_prev_key='<C-p>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<Esc>'

    " Writing in vim {{{{
        Plug 'junegunn/limelight.vim'
        Plug 'junegunn/goyo.vim'
        let g:limelight_conceal_ctermfg = 240
    " }}}

    " context-aware pasting
    Plug 'sickill/vim-pasta'

    " FZF {{{
        Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
        Plug 'junegunn/fzf.vim'
        let g:fzf_layout = { 'down': '~25%' }

        if isdirectory(".git")
            " if in a git project, use :GFiles
            nmap <silent> <leader>e :GFiles --cached --others --exclude-standard<cr>
            " nmap <c-p> :GFiles --cached --others --exclude-standard<cr>
        else
            " otherwise, use :FZF
            nmap <silent> <leader>e :FZF<cr>
            " nmap <c-p> :FZF<cr>
        endif

        nmap <c-f> :Ag<cr>
        " nmap <silent> <leader>r :Buffers<cr>
        " nmap <c-a> :Buffers<cr>
        nmap <leader><tab> <plug>(fzf-maps-n)
        xmap <leader><tab> <plug>(fzf-maps-x)
        omap <leader><tab> <plug>(fzf-maps-o)

        " Insert mode complete
        imap <c-x><c-k> <plug>(fzf-complete-word)
        imap <c-x><c-f> <plug>(fzf-complete-path)
        imap <c-x><c-j> <plug>(fzf-complete-file-ag)
        imap <c-x><c-l> <plug>(fzf-complete-line)

        nnoremap <silent> <Leader>C :call fzf#run({
        \    'source':
        \      map(split(globpath(&rtp, "colors/*.vim"), "\n"),
        \          "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')"),
        \    'sink':    'colo',
        \    'options': '+m',
        \    'left':    30
        \ })<CR>

        command! FZFMru call fzf#run({
        \  'source':  v:oldfiles,
        \  'sink':      'e',
        \  'options': '-m -x +s',
        \  'down':      '40%'})

        command! -bang -nargs=* Find call fzf#vim#grep(
            \ 'rg --column --line-number --no-heading --follow --color=always '.<q-args>, 1,
            \ <bang>0 ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?'), <bang>0)
        command! -bang -nargs=? -complete=dir Files
            \ call fzf#vim#files(<q-args>, fzf#vim#with_preview('right:50%', '?'), <bang>0)
        command! -bang -nargs=? -complete=dir GFiles
            \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview('right:50%', '?'), <bang>0)
    " }}}

    " Deoplete {{{
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
        Plug 'zchee/deoplete-jedi', { 'for' : 'python'}
        Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
        let g:deoplete#enable_at_startup = 1
        if !exists('g:deoplete#omni#input_patterns')
            let g:deoplete#omni#input_patterns = {}
        endif
        inoremap <silent><expr> <TAB>
                    \ pumvisible() ? "\<C-n>" :
                    \ <SID>check_back_space() ? "\<TAB>" :
                    \ deoplete#mappings#manual_complete()
        function! s:check_back_space() abort "{{{
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
        endfunction"}}}
    " }}}

	" {{{ "
		Plug 'kana/vim-operator-user'
		Plug 'haya14busa/vim-operator-flashy'
		map y <Plug>(operator-flashy)
		nmap Y <Plug>(operator-flashy)$
	" }}} "

    " signify {{{
        " Plug 'airblade/vim-gitgutter'
        Plug 'mhinz/vim-signify'
        let g:signify_vcs_list = [ 'git' ]
        let g:signify_sign_add                 = '+'
        let g:signify_sign_delete             = '_'
        let g:signify_sign_delete_first_line = '‾'
        let g:signify_sign_change = '!'
    " }}}

    " vim-fugitive {{{
        Plug 'tpope/vim-fugitive'
        Plug 'tpope/vim-rhubarb' " hub extension for fugitive
        nmap <silent> <leader>gs :Gstatus<cr>
		nmap <silent> <leader>gw :Gwrite<cr>
		nmap <silent> <leader>gc :Gcommit<cr>
		nmap <silent> <leader>gp :Gpush<cr>
        nmap <leader>ge :Gedit<cr>
        nmap <silent><leader>gr :Gread<cr>
        nmap <silent><leader>gb :Gblame<cr>
    " }}}

	" EasyAlign {{{ "
		" 🌻 A Vim alignment plugin
		Plug 'junegunn/vim-easy-align'
		" Start interactive EasyAlign in visual mode (e.g. vipga)
		xmap ga <Plug>(EasyAlign)

		" Start interactive EasyAlign for a motion/text object (e.g. gaip)
		nmap ga <Plug>(EasyAlign)

	"  }}} "

	" EasyMotion {{{
		Plug 'easymotion/vim-easymotion'
		nmap ff <Plug>(easymotion-prefix)
		map  / <Plug>(easymotion-sn)
		omap / <Plug>(easymotion-tn)
		map  n <Plug>(easymotion-next)
		map  N <Plug>(easymotion-prev)
	"}}}"

    " ALE {{{
        Plug 'w0rp/ale' " Asynchonous linting engine

        nmap <leader>n :ALENext<cr>
        let g:ale_change_sign_column_color = 0
        let g:ale_sign_column_always = 1
        let g:ale_sign_error = '✖'
        let g:ale_sign_warning = '⚠'

        let g:ale_linters = {
        \    'javascript': ['eslint'],
        \    'typescript': ['tsserver', 'tslint'],
        \    'html': []
        \}
        let g:ale_fixers = {}
	let g:ale_fixers['javascript'] = ['prettier', 'eslint']
	let g:ale_javascript_prettier_use_local_config = 1
	let g:ale_fix_on_save = 0
	let g:ale_completion_enabled = 1
" }}}

" VimTest {{{ "
	Plug 'janko-m/vim-test'
	let test#strategy = "vimux"
	let g:test#runner_commands = ['Jest']

	nmap <leader>t :TestNearest<CR>
	nmap <leader>f :TestFile<CR>
	nmap <leader>s :TestSuite<CR>
	" nmap tt :vs|TestVisit<CR>
" }}} "

" UltiSnips {{{
	Plug 'honza/vim-snippets'
	Plug 'SirVer/ultisnips' " Snippets plugin
	Plug 'swapkats/vim-react-snippets'
	Plug 'alexbyk/vim-ultisnips-js-testing'
	let g:UltiSnipsExpandTrigger="<C-l>"
	let g:ulti_expand_or_jump_res = 0
" }}}
" }}}

" Language-Specific Configuration {{{
" html / templates {{{
	" emmet support for vim - easily create markdup wth CSS-like syntax
	Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript.jsx', 'eruby' ]}
	let g:user_emmet_settings = {
	\  'javascript.jsx': {
	\       'extends': 'jsx',
	\  },
	\}

	" match tags in html, similar to paren support
	Plug 'gregsexton/MatchTag', { 'for': 'html' }

	" html5 support
	Plug 'othree/html5.vim', { 'for': 'html' }

	" mustache support
	Plug 'mustache/vim-mustache-handlebars'

	" pug / jade support
	Plug 'digitaltoad/vim-pug', { 'for': ['jade', 'pug'] }

	" Ruby / Ruby on Rails
	Plug 'tpope/vim-rails', { 'for': 'ruby' }
" }}}

" JavaScript {{{
	Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx', 'html'] }
	Plug 'moll/vim-node', { 'for': 'javascript' }
	Plug 'mxw/vim-jsx', { 'for': ['javascript.jsx', 'javascript'] }
	Plug 'maxmellon/vim-jsx-pretty'
    let g:xml_syntax_folding = 1
	" Fixes jsx end tag hightlight
	hi link xmlEndTag xmlTag
	" syn region xmlTagName matchgroup=xmlEndTag start=+</+ end=+>+
	Plug 'chemzqm/vim-jsx-improve'
	Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
	Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'], 'do': 'npm install' }
	Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
	Plug 'joaohkfaria/vim-jest-snippets'
	Plug 'glanotte/vim-jasmine'

	nmap <leader>p :Prettier<cr>
	let g:prettier#autoformat = 0
	let g:prettier#exec_cmd_async = 1
	let g:prettier#quickfix_enabled = 0
	let g:prettier#quickfix_auto_focus = 0
	let g:prettier#config#print_width = 140
	let g:prettier#config#single_quote = 'true'
	let g:prettier#config#trailing_comma = 'all'
	let g:prettier#config#bracket_spacing = 'true'
	let g:prettier#config#jsx_bracket_same_line = 'false'
	let g:jsx_ext_required = 0
" }}}

    " TypeScript {{{
        Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
        Plug 'Shougo/vimproc.vim', { 'do': 'make' }

        Plug 'Quramy/tsuquyomi', { 'for': 'typescript', 'do': 'npm install' }
        let g:tsuquyomi_completion_detail = 1
        let g:tsuquyomi_disable_default_mappings = 1
        let g:tsuquyomi_completion_detail = 1
    " }}}

    " Styles {{{
        Plug 'wavded/vim-stylus', { 'for': ['stylus', 'markdown'] }
        Plug 'groenewege/vim-less', { 'for': 'less' }
        Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
        Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
        Plug 'gko/vim-coloresque'
        Plug 'stephenway/postcss.vim', { 'for': 'css' }
    " }}}

    " markdown {{{
        Plug 'tpope/vim-markdown', { 'for': 'markdown' }

        " Open markdown files in Marked.app - mapped to <leader>m
        Plug 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' }
        nmap <leader>m :MarkedOpen!<cr>
        nmap <leader>mq :MarkedQuit<cr>
        nmap <leader>* *<c-o>:%s///gn<cr>
    " }}}

    " JSON {{{
        Plug 'elzr/vim-json', { 'for': 'json' }
        let g:vim_json_syntax_conceal = 0
    " }}}

    Plug 'fatih/vim-go', { 'for': 'go' }
    Plug 'timcharper/textile.vim', { 'for': 'textile' }
	Plug 'sheerun/vim-polyglot'
    Plug 'lambdatoast/elm.vim', { 'for': 'elm' }
    Plug 'tpope/vim-endwise', { 'for': [ 'ruby', 'bash', 'zsh', 'sh' ]}
    Plug 'kchmck/vim-coffee-script', { 'for': 'coffeescript' }
" }}}

call plug#end()

let base16colorspace=256  " Access colors present in 256 colorspace
colorscheme base16-default-dark
" Colorscheme and final setup {{{
    " This call must happen after the plug#end() call to ensure
    " that the colorschemes have been loaded
    " if filereadable(expand("~/.vimrc_background"))
        " let base16colorspace=256
        " source ~/.vimrc_background
    " else
        " let g:onedark_termcolors=16
        " let g:onedark_terminal_italics=1
        " colorscheme Apprentice
		" syntax enable
		" set background=dark
		" colorscheme solarized
    " endif
    syntax on
    filetype plugin indent on
    " make the highlighting of tabs and other non-text less annoying
    highlight SpecialKey ctermfg=236
    highlight NonText ctermfg=236

    " make comments and HTML attributes italic
    highlight Comment cterm=italic
    highlight htmlArg cterm=italic
    highlight xmlAttrib cterm=italic
    highlight Type cterm=italic
    highlight Normal ctermbg=none

    call deoplete#custom#source('ultisnips', 'matchers', ['matcher_fuzzy'])

" }}}

" vim:set foldmethod=marker foldlevel=0
