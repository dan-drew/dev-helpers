alias gs='git status'
alias ga='git add .'
alias gcf='git commit --fixup=HEAD'
alias gp='git push origin HEAD'
alias gpf='git push --force-with-lease origin HEAD'

readonly -a __GIT_MAIN_BRANCHES=("main" "master")

function git-main-branch() {
  local name=`git branch --no-color -l "${__GIT_MAIN_BRANCHES[@]}" | head -n1`
  if [ -n "$name" ]; then
    echo "${name:2}"
    return 0
  else
    return 1
  fi
}

function is-git-main-branch() {
  local branch="${1:-$(git branch --show-current)}"
  if [[ " ${__GIT_MAIN_BRANCHES[@]} " =~ " $branch " ]]; then
    return 0
  else
    return 1
  fi
}

function gc() {
  git commit -am "$1"
}

function gr() {
  git rebase -i --autosquash ${1:-`git-main-branch`}
}

function gl() {
  git log -n${1:-5}
}

function gls() {
  git log --oneline -n${1:-10}
}

function gcl() {
  local source_branch=${1:-`git-main-branch`}
  local current_branch=$(git branch --show-current)

  if [[ "$current_branch" != "$source_branch" ]]; then
    git checkout $source_branch
  fi

  # Update master
  git pull origin $source_branch

  # Update remote branches and purge deleted
  git fetch -p

  # Delete local branches which have been merged to master
  for branch in `git branch --format='%(refname:short)' --merged ${source_branch}`; do
    if [[ $branch != $source_branch ]]; then
      if git branch -d $branch &> /dev/null; then
        echo "Deleted merged branch $branch"
        if [[ $branch == $current_branch ]]; then
          current_branch=$source_branch
        fi
      fi
    fi
  done

  # Go back to working branch
  if [[ "$current_branch" != $source_branch ]]; then
    git checkout $current_branch
  fi
}

function git-meta-init() {
  if ! [ -d .git ]; then
    git init
  fi

  local module_origin
  local has_modules=false
  for module_directory in $(find . -mindepth 1 -maxdepth 1 -type d); do
    if [ -d "$module_directory/.git" ]; then
      module_origin=$(git -C "$module_directory" remote get-url origin)
      git submodule add "$module_origin" "$module_directory"
      has_modules=true
    fi
  done

  if $has_modules; then
    ga
    gc 'Initialize meta repository with submodules'
    __dh_success "Repo initialized. Run \"gp\" to push to remote."
  fi
}

function git-each() {
  for module_directory in $(find . -mindepth 1 -maxdepth 1 -type d); do
    if [ -d "$module_directory/.git" ]; then
      git -C "$module_directory" "$@" | awk -v module="${module_directory:2}" '{print module ": " $0}'
    fi
  done
}

function git-upstream() {
  # Get the upstream branch for the given branch, if it exists
  # If it doesn't exist, test for origin/<branch> and return that if it exists
  local -r branch="$1"
  local upstream
  upstream=$(git rev-parse --abbrev-ref "$branch@{upstream}" 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    echo "$upstream"
  else
    git rev-parse --verify "origin/$branch" 2>/dev/null && echo "origin/$branch"
  fi
}

function git-state() {
  local branch
  local status
  local upstream
  local ahead
  local behind

  branch=$(git branch --show-current)
  status=$(git status --porcelain)
  upstream=$(git-upstream "$branch")
  is_main_branch=$(is-git-main-branch "$branch" && echo true || echo false)
  ahead=0
  behind=0

  if [[ -n "$upstream" ]]; then
    read -r ahead behind < <(git rev-list --left-right --count "HEAD...$upstream")
  fi

  

  if upstream=$(git-upstream "$branch"); then
    if ! is-git-main-branch "$branch"; then
      __dh_warn "Branch '$branch' is a feature branch."
    fi

    read -r ahead behind < <(git rev-list --left-right --count "HEAD...$upstream")

    if (( behind > 0 )); then
      __dh_error "Branch '$branch' is $behind commit(s) behind '$upstream'."
    fi

    if (( ahead > 0 )); then
      __dh_warn "Branch '$branch' is $ahead commit(s) ahead of '$upstream'."
    fi
  else
    __dh_error "Branch '$branch' is not tracking a remote branch."
  fi

  if [[ ! " ${__GIT_MAIN_BRANCHES[@]} " =~ " $branch " ]]; then
    __dh_warn "Branch '$branch' is a feature branch."
  fi

  if [[ -n "$status" ]]; then
    __dh_error "Branch '$branch' has uncommitted changes."
  else
    __dh_success "Branch '$branch' is clean."
  fi
}
