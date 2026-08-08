alias gs='git status'
alias ga='git add .'
alias gcf='git commit --fixup=HEAD'
alias gp='git push origin HEAD'
alias gpf='git push --force-with-lease origin HEAD'

function git_main_branch() {
  local name=`git branch --no-color -l main master | head -n1`
  if [[ -n "$name" ]]; then
    echo "${name:2}"
    return 0
  else
    return 1
  fi
}

function gc() {
  git commit -am "$1"
}

function gr() {
  git rebase -i --autosquash ${1:-`git_main_branch`}
}

function gl() {
  git log -n${1:-5}
}

function gls() {
  git log --oneline -n${1:-10}
}

function gcl() {
  local source_branch=${1:-`git_main_branch`}
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
