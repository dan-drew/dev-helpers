readonly SHELL_INIT=". ${THIS_DIR}/shell_aliases.sh
. ${THIS_DIR}/initializers/files/shell_init.sh
PATH=\$PATH:${THIS_DIR}
"

readonly __SHELL_HELPER_DIR="$HOME/.shell-dev-helpers.d"
readonly __SHELL_INITIALIZERS_DIR="${THIS_DIR}/initializers/files"

function is_bash() {
  [ -n "$BASH_VERSION" ]
}

function is_zsh() {
  [ -n "$ZSH_VERSION" ]
}

if is_bash; then
  readonly __SHELL_RC_FILE="$HOME/.bashrc"
elif is_zsh; then
  readonly __SHELL_RC_FILE="$HOME/.zshrc"
else
  echo "Unsupported shell type!"
  exit 1
fi

function shell_reload() {
  if [[ -z "${module_state[shell_reload]}" ]]; then
    module_state[shell_reload]=1
    post_messages+=("Shell configuration changed. Run \"source $__SHELL_RC_FILE\" or log out and back in for changes to take effect.")
  fi
}

function shell_append() {
  local -r module="${1?Missing module name}"
  local -r line="${2?Missing line to append}"
  
  mkdir -p "$__SHELL_HELPER_DIR"
  echo "$line" > "$__SHELL_HELPER_DIR/${module}.sh"

  shell_reload
}

function shell_source() {
  local -r module="${1?Missing name}"
  local -r file="${2?Missing file to source}"

  if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' not found."
    return 1
  fi

  ln -sfT "$file" "$__SHELL_HELPER_DIR/${module}.sh"
}

function shell_initializer() {
  local -r module="${1?Missing module name}"
  local -r file_name="${2-${module}.sh}"
  local -r file="${__SHELL_INITIALIZERS_DIR}/$file_name"

  shell_source "$module" "$file"
}

function __shell_add_helpers() {
  touch "$__SHELL_RC_FILE"
  mkdir -p "$__SHELL_HELPER_DIR"

  local -r HELPER_PATH="${__SHELL_INITIALIZERS_DIR}/shell_helpers.sh"

  if grep -Fq "$HELPER_PATH" "$__SHELL_RC_FILE"; then
    return 0
  fi

  printf '\n. %s\n' "$HELPER_PATH" >> "$__SHELL_RC_FILE"
  shell_reload
}

function install_shell() {
  __shell_add_helpers

  shell_initializer 00_shell_init shell_init.sh
  shell_initializer shell_aliases
  shell_reload
}
