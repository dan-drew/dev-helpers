function __is_bash() {
  [ -n "$BASH_VERSION" ]
}

function __is_zsh() {
  [ -n "$ZSH_VERSION" ]
}

if ! ( __is_bash || __is_ssh ); then
  echo "Unsupported shell"
  exit 1
fi

function __dev_helpers_reverse_path() {
  local -r path="$1"
  local reversed=""
  local component
  local i
  local -a components

  IFS='/' read -r -a components <<< "$path"
  for ((i=${#components[@]} - 1; i >= 0; i--)); do
    component="${components[$i]}"
    [[ -z "$component" ]] && continue
    reversed+="${reversed:+/}${component}"
  done

  if [[ "$path" == /* ]]; then
    reversed="${reversed}/"
  fi

  printf '%s' "${reversed:-/}"
}

function __dev_helpers_escape_prompt_text() {
  local text="$1"

  text=${text//\\/\\\\}
  text=${text//\$/\\$}
  text=${text//\`/\\\`}

  printf '%s' "$text"
}

declare -a __dev_helpers_prompts=( __dev_helpers_prompt_path )

function __dev_helpers_prompt_path() {
  local prompt_path="$PWD"
  local title

  if [[ "$PWD" == "$HOME" ]]; then
    prompt_path="~"
  elif [[ "$PWD" == "$HOME/"* ]]; then
    prompt_path="~/${PWD#"$HOME/"}"
  fi

  title=$(__dev_helpers_reverse_path "$prompt_path")
  title=${title//$'\e'/}
  title=${title//$'\a'/}
  title=$(__dev_helpers_escape_prompt_text "$title")

  prompt_path=$(__dev_helpers_escape_prompt_text "$prompt_path")
  echo '\[\e]0;'"$title"'\a\]\[\e[32m\]'"$prompt_path"

  if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    branch=$(__dev_helpers_escape_prompt_text "$branch")
    PS1+='\[\e[34m\]'"[$branch]"
  fi

  if [[ -f terragrunt.hcl ]] &&
    workspace=$(terragrunt --log-format bare run -- workspace show 2>/dev/null); then
    workspace=$(__dev_helpers_escape_prompt_text "$workspace")
    PS1+='\[\e[38;5;208m\]'"[$workspace]"
  elif [[ -f main.tf || -f variables.tf || -f outputs.tf || -f terraform.tf ]] &&
    workspace=$(terraform workspace show 2>/dev/null); then
    workspace=$(__dev_helpers_escape_prompt_text "$workspace")
    PS1+='\[\e[38;5;208m\]'"[$workspace]"
  fi

}

function __dev_helpers_prompt() {
  local prompt=''
  local fn

  for fn in "${__dev_helpers_prompts[@]}"; do
    prompt+=$( $fn )
  done

  PS1="$prompt"
  PS1+='\[\e[32m\]$ \[\e[0m\]'
}

case "${PROMPT_COMMAND:-}" in
  *__dev_helpers_prompt*) 
    ;;
  *) 
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__dev_helpers_prompt" 
    ;;
esac

export PATH="$HOME/.local/bin:$PATH"
