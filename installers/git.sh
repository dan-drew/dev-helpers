function install_git() {
  if ! test_command git version; then
    if $is_linux; then
      install_git_linux
    elif $is_apple; then
      install_git_mac
    else
      echo "Unsupported OS: $(uname)"
      exit 1
    fi
  fi

  require shell
  shell_initializer 10_git_prompt git_prompt.sh
  shell_initializer git_aliases
}

function install_git_linux() {
  require apt
  apt_install git
}

function install_git_mac() {
  brew install git
}
