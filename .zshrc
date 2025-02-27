setopt INC_APPEND_HISTORY

setopt PROMPT_SUBST
PROMPT=""

# last component of pwd
PROMPT+='%F{green}%1~'

PROMPT+='%F{cyan}$(prompt_nix_shell)'
function prompt_nix_shell() {
  [[ -n $IN_NIX_SHELL ]] && echo " $name"
}

PROMPT+='%F{blue}$(prompt_git_branch)'
function prompt_git_branch() {
  git branch 2>/dev/null | sed -ne 's/^\* \(.*\)/ [\1]/p'
}

if [[ -z $ORIG_SHLVL ]]; then
  export ORIG_SHLVL=$SHLVL
fi
if [[ $SHLVL -gt $ORIG_SHLVL ]]; then
  PROMPT+=" %F{red}(⥥ $(($SHLVL - $ORIG_SHLVL)))"
fi

# reset color & literal %
PROMPT+=' %f%% '
