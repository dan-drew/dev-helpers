declare -A __dev_helpers_terraform_workspace_cache=( [workspace]='' [dir]='*' )

function __is_terraform() {
  [[ -f main.tf || -f variables.tf || -f outputs.tf || -f terraform.tf ]]
}

function __is_terragrunt() {
  [ -f terragrunt.hcl ]
}

function __terraform() {
  if __is_terragrunt; then
    terragrunt --log-format bare run -- "$@"
  else
    terraform "$@"
  fi
}

function __assert_terraform() {
  if ! __is_terraform; then
    echo "This is not a terraform module." >&2
    return 1
  fi
}

function __dev_helpers_terraform_update_workspace() {
  workspace=$(tfw 2>/dev/null)
  if [ -n "$workspace" ]; then
    workspace=$(__dev_helpers_escape_prompt_text "$workspace")
  fi

  __dev_helpers_terraform_workspace_cache[workspace]="$workspace"
  __dev_helpers_terraform_workspace_cache[dir]="$dir"
}

function __dev_helpers_terraform_refresh_workspace() {
  if ! ( __is_terragrunt || __is_terraform ); then
    __dev_helpers_terraform_workspace_cache=()
    return 0
  fi

  local workspace
  local -r dir="$(pwd)"

  if ! [ "$dir" == "${__dev_helpers_terraform_workspace_cache[dir]}" ]; then
    __dev_helpers_terraform_update_workspace
  fi
}

function tfa() {
  local -a args

  __assert_terraform || return 1

  __dev_helpers_help "$1" <<-HELP || return 0
    Apply Terraform changes.

    Syntax: tfa [-a] [target ...]

    -a        Auto-approve changes
    target    One or more targets to apply (default: all)
HELP

  if [ "$1" == "-a" ]; then
    args+=("-auto-approve")
    shift
  fi

  while [ -n "$1" ]; do
    args+=("-target=$1")
    shift
  done

  __terraform apply "${args[@]}"
}

function tfd() {
  local -a args

  __assert_terraform || return 1

  __dev_helpers_help "$1" <<-HELP || return 0
    Destroy Terraform resources.

    Syntax: tfd [target ...]

    target    One or more targets to apply (default: all)
HELP

  while [ -n "$1" ]; do
    args+=("-target=$1")
    shift
  done

  __terraform apply "${args[@]}"
}

function tfi() {
  __assert_terraform || return 1

  __dev_helpers_help "$1" <<-HELP || return 0
    Initialize Terraform module.

    Syntax: tfi
HELP

  __terraform init "$@"
}

function tfp() {
  local -a args
  local with_less=false

  __assert_terraform || return 1

  __dev_helpers_help "$1" <<-HELP || return 0
    Terraform plan.

    Syntax: tfp [-l] [target ...]

    -l      Pipe output to less
    target  Limit plan to specific resources
HELP

  while [ -n "$1" ]; do
    case "$1" in
      -l)
        with_less=true
        ;;
      -*)
        args+=("$1")
        ;;
      *)
        args+=("-target=$1")
        ;;
    esac
    shift
  done

  if $with_less; then
    __terraform plan "${args[@]}" 2>&1 | less -R
  else
    __terraform plan "${args[@]}"
  fi
}

function tfw() {
  __assert_terraform || return 1

  __dev_helpers_help "$1" <<-HELP || return 0
    Terraform workspace commands.

    tfw
      Show the current workspace

    tfw <workspace>
      Switch the current workspace

    tfw <-l|--list|list|-a|all>
      List all workspaces

    tfw <new|create> <workspace>
      Create a new workspace
HELP

  case "$1" in
    "")
      __terraform workspace show
      ;;
    -l|list|--list|-a|all)
      __terraform workspace list
      ;;
    new|create)
      __terraform workspace new "${2?Workspace name is required}"
      __dev_helpers_terraform_update_workspace
      ;;
    *)
      __terraform workspace select "$1"
      __dev_helpers_terraform_update_workspace
      ;;
  esac
}
