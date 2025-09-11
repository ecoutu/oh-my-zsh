# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

if [[ -f ~/.eco_env_common.zsh ]]; then
  source ~/.eco_env_common.zsh
fi

if [[ -f ~/.eco_env.zsh ]]; then
  source ~/.eco_env.zsh
fi


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="afowler"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
 CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="false"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=1

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="false"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

export FZF_BASE="${HOME}/.asdf/installs/fzf/0.52.1"

cdpath=(
  ${cdpath[@]}
  ${ECO_ROOT}
  ${EMPLOYER_ROOT}
)

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  mise
  # adb
  # autojump
  # aws
  # colored-man-pages
  # colorize
  # command-not-found
  # common-aliases
  # copybuffer
  # copydir
  # copyfile
  # cp
  # dircycle
  # direnv
  # dirhistory
  # dirpersist
  # docker
  # docker-compose
  # doctl
  # dotenv
  # dotnet
  # emoji
  # emoji-clock
  # emotty
  # encode64
  # fd
  fzf
  # gcloud
  # gem
  # git
  # git-escape-magic
  # git-lfs
  # git-prompt
  # gitignore
  # # globalias
  # golang
  # history
  # history-substring-search
  # jsontools
  # jump
  # nmap
  # node
  # npm
  # otp
  # pass
  # percol
  # pip
  # pipenv
  # pj
  # profiles
  # python
  # rsync
  # ruby
  # sudo
  # systemadmin
  # systemd
  # timer
  # tmux
  # tmux-cssh
  # ubuntu
  # virtualenv
  # vscode
  # wakeonlan
  # wd
  # web-search
  # urltools
  # # z
  zoxide
  # zsh_reload
  # zsh-interactive-cd
  # zsh-navigation-tools
)

source $ZSH/oh-my-zsh.sh

# User configuration

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
cdpath+=(
  ${HOME}
  ${DEV_ROOT}
  ${ECO_SRC}
  ${EMPLOYER_SRC}
)

# Set the list of directories that Zsh searches for programs.
path+=(
  ${HOME}/.local/{,s}bin
  ${HOME}/{,s}bin(N)
  # /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
)


PROJECT_PATHS=(~/ecoutu/src)

if [[ -d "${HOME}/.zsh" ]]; then
  for file in ${HOME}/.zsh/*; do
    if [[ ! -d "${file}" ]]; then
      source "${file}"
    fi
  done
fi

# autoload -U +X bashcompinit && bashcompinit

# ### ZNT's installer added snippet ###
# fpath=("$fpath[@]" "$HOME/.config/znt/zsh-navigation-tools")
# autoload n-aliases n-cd n-env n-functions n-history n-kill n-list n-list-draw n-list-input n-options n-panelize n-help
# autoload znt-usetty-wrapper znt-history-widget znt-cd-widget znt-kill-widget
# alias naliases=n-aliases ncd=n-cd nenv=n-env nfunctions=n-functions nhistory=n-history
# alias nkill=n-kill noptions=n-options npanelize=n-panelize nhelp=n-help
# zle -N znt-history-widget
# bindkey '^R' znt-history-widget
# setopt AUTO_PUSHD HIST_IGNORE_DUPS PUSHD_IGNORE_DUPS
# zstyle ':completion::complete:n-kill::bits' matcher 'r:|=** l:|=*'
# ### END ###

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code --wait --new-window'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
