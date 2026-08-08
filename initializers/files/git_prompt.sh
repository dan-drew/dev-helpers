function __dev_helpers_git_branch_prompt() {
  local branch

  if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    branch=$(__dev_helpers_escape_prompt_text "$branch")
    echo '\[\e[34m\]'"[$branch]"
  fi
}

__dev_helpers_prompts+=( __dev_helpers_git_branch_prompt )
