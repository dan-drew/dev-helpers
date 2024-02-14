# Include this in .bashrc for handy shortcuts
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

function hg() {
  history | grep "$1" | uniq -f 1 | tail -n10
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

