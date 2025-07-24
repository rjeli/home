setopt INC_APPEND_HISTORY

# ===== PROMPT =====

setopt PROMPT_SUBST
PROMPT=""

# last component of pwd
PROMPT+='%F{green}%1~'

PROMPT+='%F{cyan}$(prompt_nix_shell)'
function prompt_nix_shell() {
  [[ -n $IN_NIX_SHELL ]] && echo " $name"
}

# PROMPT+='%F{blue}$(prompt_git)'
PROMPT+='$(prompt_vcs)'

function prompt_vcs() {
    jj root --quiet &>/dev/null && prompt_jj || prompt_git
}

function prompt_git() {
  echo -n '%F{blue}'
  git branch 2>/dev/null | sed -ne 's/^\* \(.*\)/ [\1]/p'
}

function prompt_jj() {
    echo -n ' '
    jj log -r 'latest(ancestors(@, 10) ~ (empty()~merges()))' \
        --quiet --no-pager --no-graph --ignore-working-copy --color always \
        -T "surround('(', ')', separate(' ', \
            self.local_bookmarks(), \
            self.change_id().shortest(5)\
        ))" 2>/dev/null

        #   coalesce(self.description().first_line(), '...'), \
}

function prompt_jj_2() {
    jj log -r@ -n1 --ignore-working-copy --no-graph --color always -T '
        separate(" ",
            bookmarks.map(|x| truncate_end(8, x.name(), "…")).join(" "),
            tags.map(|x| truncate_end(8, x.name(), "…")).join(" "),
            surround("\"","\"", truncate_end(8, description.first_line(), "…")),
            change_id.shortest(5),
            commit_id.shortest(5),
            if(empty, "(empty)"),
            if(conflict, "(conflict)"),
            if(divergent, "(divergent)"),
            if(hidden, "(hidden)"),
        )
    '
}

if [[ -z $ORIG_SHLVL ]]; then
  export ORIG_SHLVL=$SHLVL
fi
if [[ $SHLVL -gt $ORIG_SHLVL ]]; then
  PROMPT+=" %F{red}(⥥ $(($SHLVL - $ORIG_SHLVL)))"
fi

# reset color & literal %
PROMPT+=' %f%% '

# source "$HOME/.zshrc_extra"

# === ALIASES ===

# alias zed="$HOME/Applications/Zed.app/Contents/MacOS/cli"

# === FUNCTIONS ===

rsyncgi () {
    [ $# -ne 1 ] && echo "usage: rsyncgi remote:path" && exit 1
    [[ "${1: -1}" == "/" ]] && echo "not recommended to end remote path with slash" && exit 1
    rsync -vhra . "$1" --include='**.gitignore' --exclude='/.git' --filter=':- .gitignore' --delete-after
}

# "gs-setup HOST"
#  - Creates a bare repo on HOST at ~/.gitsync/<project>.git
#  - Sets up a post-receive hook that checks out into ~/repos/<project>
gs-setup () {
  if [[ -z "$1" ]]; then
    echo "Usage: gs-setup <host>"
    return 1
  fi

  local host=$1
  local project
  project=$(basename "$PWD")

  echo "Setting up git sync on $host for project: $project"

  ssh "$host" /bin/bash <<EOF
    set -e
    mkdir -p ~/.gitsync
    mkdir -p ~/repos
    cd ~/.gitsync

    if [[ ! -d "$project.git" ]]; then
      git init --bare -b master "$project.git"

      cat <<'HOOK' >"$project.git/hooks/post-receive"
#!/usr/bin/env bash
set -e
export GIT_WORK_TREE="\$HOME/repos/PROJECT"
mkdir -p "\$GIT_WORK_TREE"
git checkout -f
HOOK

      sed -i "s/PROJECT/$project/g" "$project.git/hooks/post-receive"
      chmod +x "$project.git/hooks/post-receive"
      echo "Created bare repo ~/.gitsync/$project.git with post-receive hook."
    else
      echo "Repo ~/.gitsync/$project.git already exists on $host."
    fi
EOF
}

# "gs HOST"
#  - Pushes local HEAD into ~/.gitsync/<project>.git on HOST
#  - That triggers the checkout hook to update ~/repos/<project> on HOST
gs () {
  if [[ -z "$1" ]]; then
    echo "Usage: gs <host>"
    return 1
  fi

  local host=$1
  local project
  project=$(basename "$PWD")

  echo "Pushing local HEAD to $host:~/.gitsync/$project.git"
  git push "ssh://$host/~/.gitsync/$project.git" HEAD:master
}
