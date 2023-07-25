if [ -r .config/bash/environment -a -z "$__USER_ENVIRONMENT_SET" ]; then
  source .config/bash/environment
  export __USER_ENVIRONMENT_SET=1
fi

alias cp='cp -i --reflink=auto'
alias dd='tisdone dd status=progress'
alias sudd='tisdone sudo dd status=progress'
alias e='nvim -p'
alias grep='grep --color=auto'
alias htop='htop -d20'
alias ip='ip --color=auto'
alias ip4='ip -4 --color=auto'
alias ip6='ip -6 --color=auto'
alias l='ls --color=auto --quoting-style=literal'
alias la='ls -Ahl --color=auto --quoting-style=literal'
alias less='less -FX'
alias make='tisdone make'
alias mit-scheme='rlwrap mit-scheme'
alias mupdf='mupdf-x11'
alias mv='mv -i'
alias nix-build='tisdone nix-build'
alias py='python3'
alias rg='rg -S'
alias rsync='tisdone rsync --progress'
alias tclsh='rlwrap tclsh'
alias vim='nvim -p'
alias watch='watch --color'

function enter {
  pushd "$1" && nix-shell; popd || return
}

function rest {
  i3-msg exec -- st -d "$PWD" >/dev/null
}

function dims {
  echo "$(tput cols)x$(tput lines)"
}
