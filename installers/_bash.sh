readonly BASH_INIT=". ${THIS_DIR}/bash_aliases.sh
. ${THIS_DIR}/initializers/files/bash_init.sh
PATH=\$PATH:${THIS_DIR}
"

function bash_reload() {
  if [[ -z "${module_state[bash_reload]}" ]]; then
    module_state[bash_reload]=1
    post_messages+=("Bash configuration changed. Run \"source $HOME/.bashrc\" or  log out and back in for changes to take effect.")
  fi
}

function bash_append() {
  local -r module="${1?Missing module name}"
  local -r line="${2?Missing line to append}"
  
  mkdir -p "$HOME/.bash-dev-helpers.d"
  echo "$line" > "$HOME/.bash-dev-helpers.d/$module"

  bash_reload
}

function ensure_bashrc_sourcing() {
  local -r bashrc_file="$HOME/.bashrc"
  local -r marker="# bash-dev-helpers auto-load"

  touch "$bashrc_file"

  if grep -Fq "$marker" "$bashrc_file"; then
    return 0
  fi

  printf '\n' >> "$bashrc_file"

  cat <<'EOF' >> "$bashrc_file"
# bash-dev-helpers auto-load
if [ -d "$HOME/.bash-dev-helpers.d" ]; then
  for f in "$HOME/.bash-dev-helpers.d"/*; do
    [ -f "$f" ] && . "$f"
  done
fi
EOF

  bash_reload
}

function install_bash() {
  ensure_bashrc_sourcing

  bash_append "bash" "$BASH_INIT"
  bash_reload
}
