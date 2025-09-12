# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"




# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi


# Source/Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powelevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
# zinit snippet OMPZ::sudo
# zinit snippet OMPZ::archlinux
# zinit snippet OMPZ::git
# zinit snippet OMPZ:: command-not-found

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
# the below alias opens firefox and navigates to the desired website, howeever since the process is attached to the terminal from which it is called
# the applocation closes along with the terminal.
    # alias firefox="nohup flatpak run --filesystem=home org.mozilla.firefox 2>/dev/null"
# the below alias opens firefox in a detached state, however, it does not navigate to any soecified website as "alias" expands the command literally
# and a website address is not a command
    # alias firefox="nohup flatpak run --filesystem=home org.mozilla.firefox >/dev/null 2>&1 &"


# Shell integrations
eval "$(fzf --zsh)"

# Function to open firefox in a detached state and be able to navigate to a specifice website simultaneously
firefox() {
  nohup /usr/bin/firefox "$@" >/dev/null 2>&1 &
  disown
}

# Function to mount the shared folder from windows at ~/winshare. The script file (.sh) for this is located at ~/myScripts
winshare() {
  "$HOME/myScripts/connect_Windows.sh" "$@"
}

checkHealth() {
  "$HOME/myScripts/check_Health.sh" "$@"
}

