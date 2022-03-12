export EDITOR=nvim
export GOPROXY=direct
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1048576
export HISTSIZE=1048576
export NIX_PATH=nixpkgs=$HOME/cfg/nixpkgs
export NIXOS_MACHINES=$HOME/c/dev

alias cp='cp -i --reflink=auto'
alias dd='tisdone dd status=progress'
alias e='nvim'
alias grep='grep --color=auto'
alias htop='htop -d20'
alias ip6='ip -6'
alias l='ls --color=auto --quoting-style=literal'
alias la='ls -hal --color=auto --quoting-style=literal'
alias make='tisdone make'
alias mit-scheme='rlwrap mit-scheme'
alias mupdf='mupdf-x11'
alias mv='mv -i'
alias nix-build='tisdone nix-build'
alias py='python'
alias rg='rg -S'
alias rsync='tisdone rsync --progress'
alias tclsh='rlwrap tclsh'
alias vim='nvim'
alias watch='watch --color'

function enter {
  pushd "$1" && nix-shell; popd || return
}

function rest {
  st -d "$PWD" 2>/dev/null >/dev/null &
}
