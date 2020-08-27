# dotfiles

My personal dev setup. Includes config files for tmux, NeoVim, zsh. Optimized to improve speed, and keep your hands on home row. Tries to reduce cost of context switch.

![tmux + NeoVim setup](https://i.imgur.com/Jo4F4b1.png)

## tmux config

* tmux config extends [gpakosz/.tmux](https://github.com/gpakosz/.tmux). 
* changes to colorscheme to match *base16-default-dark* colorscheme. 
* applescript displays itunes and spotify track on status line
* M-j for tmux prefix. Use stronger index to move between both tmux and vim splits

## NeoVim setup

Map your caps lock to ctrl for best experience.

* Uses vim-plug
* Uses ``,`` for leader
* Works great for react development and tdd. Includes sensible plugins like
    - Ultisnips
    - vim-react-snippets
    - vim-jest-snippets
    - istanbul
    - vim-test
    - vim-jsx
    - vim-prettier
    - vim-styled-components
* Switching to normal mode saves buffer
* Some notable plugins include
    - vim-commentary
    - vim-surround
    - vim-repeat
    - netrw istead of NerdTree
    - FastFold
    - vim-stay
    - vimwiki
    - fzf
    - deoplete
    - vim-fugitive
    - EasyMotion
    - Ale for linting
    - vim-rails
    - vim-markdown

## colorscheme

iTerm2, NeoVim and tmux all use same color scheme *base16-default-dark*

# fonts

* Uses *Fira Code* without ligature. Disabling ligatures helps iTerm2 use gpu. 
* *Hack regular code nerd complete* for icons in iTerm2.

