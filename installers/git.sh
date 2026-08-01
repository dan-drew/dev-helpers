function check_git() {
  has_command git
}

function install_git() {
  if $is_linux; then
    install_git_linux
  elif $is_apple; then
    install_git_mac
  else
    echo "Unsupported OS: $(uname)"
    exit 1
  fi
}

function install_git_linux() {
  require apt
  apt_install git
}

function install_git_mac() {
  brew install git
}
