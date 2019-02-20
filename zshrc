if [[ -f ~/.profile ]]; then
  source ~/.profile
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
if [[ -f ~/.zshrc.theme ]]; then
  ZSH_THEME=$(cat ~/.zshrc.theme)
else
  ZSH_THEME="robbyrussell"
fi


# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
if [[ `uname` == 'Darwin' ]] then
  plugins=(brew compleat catimg gitfast sublime vagrant vi-mode autojump)
else
  plugins=(compleat catimg gitfast sublime vagrant vi-mode autojump)
fi

source $ZSH/oh-my-zsh.sh


# User configuration

export PATH="./.bundle/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/lib/node_modules"
if ! (command -v rvm >/dev/null 2>&1 ); then
  export PATH="${HOME}/.rbenv/bin:${PATH}"
fi

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

source $(brew --prefix nvm)/nvm.sh


alias ..1='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'
alias l='ls -CF'
if (command exa -v >/dev/null 2>&1 ); then
  alias ls='exa'
fi
alias -- +='pushd .'
alias -- -=popd
alias .f='cd ~/.bin/dotfiles'
alias c='cd ~/_code'

if (command bat -v >/dev/null 2>&1 ); then
  alias cat='bat' # bat is cat command on steroids https://github.com/sharkdp/bat
fi

alias be='bundle exec'
if (command -v rvm >/dev/null 2>&1 ); then
  alias bi='bundle check --path=.bundle || bundle install --path=.bundle --binstubs .bundle/bin --jobs=4 --retry=3'
  alias bu='bundle update --path .bundle --verbose --binstubs .bundle/bin'
else
  alias bi='bundle check --path=.bundle || bundle install --path=.bundle --binstubs .bundle/bin --jobs=4 --retry=3; rbenv rehash'
  alias bu='bundle update --path .bundle --verbose --binstubs .bundle/bin; rbenv rehash'
fi

alias esli='eslint'
alias eslintfix='eslint --fix'
alias git=hub
alias brucop='bundle exec rubocop -a -D $(git diff --cached --name-only --diff-filter=d HEAD | egrep ".(rb|rake)$" | egrep -v "db\/schema.rb" | egrep -v "lib\/pb") Gemfile'
alias bife='bundle exec knife'
alias bagrant='bundle exec vagrant'
alias brake='bundle exec foreman run rake'
alias brails='bundle exec foreman run rails'
alias brespec='SHOW_COUNTS=on bundle exec rspec --color --drb'
alias boreman='reset && bundle exec foreman start'
alias bap='bundle exec cap'
alias laptop_pg_create_user='createuser -d -s -P'
alias npmlist='npm list -g --depth 0'
alias x='exit'

alias rscp="rsync --partial --progress --rsh=ssh"
alias convim='vim -u /usr/share/vim/vimrc'

alias ios_log='tail -f ~/Library/Logs/CoreSimulator/*/system.log'

export RSPEC=true
export EDITOR=nvim

function cdbundle() {
  TARGET=$@
  if [ "x$TARGET" == "x" ]; then
    echo "Usage: cdbundle <gem>"
  fi
  dir=`bundle show "$@"`
  echo $dir
  cd $dir
}

function laptop_mysql_create_user() {
  if [ "x$1" == "x" ]; then
    echo "No username or password given.  Usage: laptop_mysql_create_user <user> <password>"
    exit 1
  fi
  if [ "x$2" == "x" ]; then
    echo "No password given.  Setting it to blank"
  fi
  mysql -uroot -p --password="" -e "GRANT ALL PRIVILEGES ON *.* TO '$1'@'localhost' IDENTIFIED BY '$2'"
}

function laptop_mysql_drop_user() {
  if [ "x$1" == "x" ]; then
    echo "No username given.  Usage: laptop_mysql_drop_user <user>"
    exit 1
  fi
  mysql -uroot -p  --password="" -e "DROP USER '$1'@'localhost'"
}


if ! (command -v rvm >/dev/null 2>&1 ); then
  eval "$(rbenv init - --no-rehash zsh)"
fi

set -o vi
bindkey -v
bindkey '^R' history-incremental-search-backward

CDPATH=.:$HOME:$HOME/_code

export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.bin.local:$PATH"


export PATH="/usr/local/sbin:$PATH"
export PATH="$PATH:./node_modules/.bin:./vendor/node_modules/.bin"
export PATH="/usr/local/anaconda3/bin:$PATH"
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
export JRUBY_OPTS='--dev'

if (command -v docker-machine >/dev/null 2>&1 ); then
  #eval $(docker-machine env default)
fi

###-tns-completion-start-###
if [ -f /Users/anshul/.tnsrc ]; then
    source /Users/anshul/.tnsrc
fi
###-tns-completion-end-###
export PATH="/usr/local/opt/libxml2/bin:$PATH"

BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"
