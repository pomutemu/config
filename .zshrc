# Preprocess

[[ -e ~/.zenv ]] && source ~/.zenv

# Options

setopt auto_cd
setopt bsd_echo
setopt glob_dots
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt list_packed
setopt magic_equal_subst
setopt menu_complete
setopt no_bang_hist
setopt no_flow_control
setopt no_nomatch
setopt share_history

# Styles

zstyle ":chpwd:*" recent-dirs-file ~/.zdirs
zstyle ":chpwd:*" recent-dirs-max 10000
zstyle ":completion:*" cache-path ~/.zcompcache
zstyle ":completion:*" completer _expand_alias _complete
zstyle ":completion:*" list-colors "${(s/:/)LS_COLORS}"
zstyle ":completion:*" matcher-list "r:|{-.:_}=*" "m:{a-z}={A-Z} r:|{-.:_}=**"
zstyle ":completion:*" menu select interactive
zstyle ":completion:*" use-cache true

# Functions

autoload -Uz add-zsh-hook
autoload -Uz cdr
autoload -z chpwd-ls
autoload -Uz chpwd_recent_dirs
autoload -Uz compinit
autoload -Uz l
autoload -Uz precmd-prompt
autoload -Uz zed
autoload -Uz zgen

add-zsh-hook chpwd chpwd-ls
add-zsh-hook chpwd chpwd_recent_dirs
add-zsh-hook precmd precmd-prompt

# Compinit

compinit -d ~/.zcompdump

# Zgen

if ! zgen saved; then
  zgen load zsh-users/zaw
  zgen load zsh-users/zsh-completions src

  zgen save
fi

# Key functions

autoload -Uz backward-delete-char-or-region
autoload -Uz delete-char-or-list-or-region
autoload -Uz kill
autoload -Uz select-line
autoload -Uz smart-expand-or-complete
autoload -Uz smart-insert-last-word

zle -N backward-delete-char-or-region
zle -N delete-char-or-list-or-region
zle -N kill
zle -N select-line
zle -N smart-expand-or-complete
zle -N smart-insert-last-word

# Key bindings

[[ -e ~/".zkbd/${TERM}-${OSTYPE}" ]] && source ~/".zkbd/${TERM}-${OSTYPE}"

bindkey "${key[ENTER]}" accept-line
bindkey "${key[TAB]}" smart-expand-or-complete
bindkey "${key[BS]}" backward-delete-char-or-region
bindkey "${key[DEL]}" delete-char-or-list-or-region
bindkey "${key[INS]}" smart-insert-last-word
bindkey "${key[HOME]}" beginning-of-line
bindkey "${key[END]}" end-of-line
bindkey "${key[LEFT]}" backward-char
bindkey "${key[RIGHT]}" forward-char
bindkey "${key[UP]}" up-line-or-history
bindkey "${key[DOWN]}" down-line-or-history

bindkey "${key[S_ENTER]}" self-insert-unmeta

bindkey \\C-q push-line-or-edit
bindkey \\C-x kill
bindkey \\C-l select-line
# bindkey \\C-d select-word
# bindkey \\C-c sigint
# bindkey "${key[C_ENTER]}" smart-insert-last-word-and-accept-line
bindkey \\C-y redo
bindkey \\C-h zaw-cdr
bindkey \\C-r zaw-history
bindkey "${key[C_BS]}" backward-delete-word
# bindkey \\C-v yank
bindkey "${key[C_DEL]}" delete-word
bindkey "${key[C_SPACE]}" set-mark-command
bindkey \\C-z undo
bindkey "${key[C_HOME]}" beginning-of-buffer-or-history
bindkey "${key[C_END]}" end-of-buffer-or-history
bindkey "${key[C_LEFT]}" backward-word
bindkey "${key[C_RIGHT]}" forward-word

bindkey -M filterselect "${key[ENTER]}" accept-line
bindkey -M filterselect "${key[TAB]}" select-action
bindkey -M filterselect "${key[BS]}" undo

bindkey -M filterselect "${key[S_ENTER]}" accept-search

zmodload zsh/complist

bindkey -M menuselect "${key[ENTER]}" .accept-line
bindkey -M menuselect "${key[TAB]}" infer-next-history
bindkey -M menuselect "${key[BS]}" undo
bindkey -M menuselect "${key[SPACE]}" accept-and-menu-complete

bindkey -M menuselect "${key[S_ENTER]}" accept-search

bindkey -N zed main

bindkey -M zed "${key[ENTER]}" self-insert-unmeta

bindkey -M zed \\C-w accept-line

# Aliases

alias e=ghq-foreach
alias f="ghq get"
alias g=hub
alias i=ghq-import-starred
alias u=ghq-update-starred

alias bench="while true; do date; done | uniq -c"
alias cp="cp -ai"
alias curl="curl -L"
alias cx="\\curl -X"
alias iip="curl -4 https://ifconfig.io/ip"
alias ll="ls -hlG"
alias ln="ln -is"
alias ls="ls -ACFH --color"
alias lu="\\ls -AHU"
alias mkdir="mkdir -p"
alias mv="mv -i"
alias nlg="npmlist -g"
alias nll="npmlist -l"
alias ph="pt --hidden"
alias pt="pt -ef --global-gitignore -C 1"
alias raw="sed -n l"
alias reload="exec zsh -i"
alias rm="rm -rI"
alias rsync="rsync -avF"

alias -g -- --h=--help
alias -g -- --s=--save
alias -g -- --S=--save-dev

alias -g C="| clip"
alias -g E="| sed -Ee"
alias -g F="| rtail -m --id"
alias -g G="| pt"
alias -g H="| ph"
alias -g J="| jq -r"
alias -g K="| grep -c"
alias -g L="| ${PAGER}"
alias -g N="| tr $'\n' \" \""
alias -g P="| peco"
alias -g Q="| sed -Ee 's/^(.+)$/\"\\1\"/'"
alias -g X="| xargs"
alias -g Y="| xargs -i{}"

# Compdef

compdef g=git

# Postprocess

[[ -e ~/.zshrc.os ]] && source ~/.zshrc.os
