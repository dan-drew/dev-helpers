function __dev_helpers_terraform_workspace_prompt() {
  local -r workspace="${__dev_helpers_terraform_workspace_cache[workspace]}"

  if [ -n "$workspace" ]; then
    echo '\[\e[38;5;208m\]'"[$workspace]"
  fi
}

__dev_helpers_prompts+=( __dev_helpers_terraform_workspace_prompt )

PROMPT_COMMAND='__dev_helpers_terraform_refresh_workspace; '"$PROMPT_COMMAND"
