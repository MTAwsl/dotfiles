# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Hide terminal context
prompt_context(){}

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting tmux)

# [[ -z "${VSCODE}" ]] && ZSH_TMUX_AUTOSTART=true
source $ZSH/oh-my-zsh.sh

bindkey '^I'   complete-word       # tab          | complete
bindkey '^[[Z' autosuggest-accept  # shift + tab  | autosuggest
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(buffer-empty bracketed-paste accept-line push-line-or-edit)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true

alias pr='export all_proxy=socks5://localhost:7890;export http_proxy=http://localhost:7890; export https_proxy=http://localhost:7890'
alias nopr='unset all_proxy http_proxy https_proxy'
alias py='python3.13'
alias python='ipython'
alias python3='python3.13'
alias pip='python3 -m pip'
alias aria2p='aria2p -p 16800 -s wUr8g4USF7Sx'
alias vim='lvim'
alias home-forward='tmux new-window -n Home-SSH ssh BhP-Laptop -L localhost:2222:localhost:22 -L localhost:5900:localhost:5900'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# iTerm2 Shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=NO

# Enable Python virtual environment
source ~/.virtualenvs/global/bin/activate

# Use lf-shellcd
source ~/.config/lf-shellcd/lf-shellcd

export PATH="$PATH:/opt/pypy3.9-v7.3.11-macos_arm64/bin"
export PATH="/Users/socular/.local/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/MonkeyDev/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
export LIBRARY_PATH="$LIBRARY_PATH:$(brew --prefix)/lib"
export CPATH="$(brew --prefix)/include:$CPATH"

export LANG=en_US.UTF-8

export MonkeyDevPath=/opt/MonkeyDev
export MonkeyDevDeviceIP=

export VISUAL=lvim
export EDITOR=lvim

# Disable built-in command r
disable r

# Automatically start ssh-agent by Joseph M. Reagle
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    #echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    #echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add --apple-use-keychain 2>&- 1>&- 0<&- || {
        echo "An error occured when adding private keys using ssh-add"
    };
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
     start_agent;
fi

function ed-submit {
  git status > /dev/null
  if [[ $? -ne 0 ]]; then
    # git will handle stderr msg
    return
  fi
  git add -A
  commit_msg=$(curl -s https://whatthecommit.com/index.txt 2>&-)
  if [[ $? -ne 0 ]]; then
    commit_msg="bluhbluhbluh"
  fi
  
  git commit -m"$commit_msg"
  if [[ $? -ne 0 ]]; then
    # git will handle stderr msg
    return
  fi
  git push
}
