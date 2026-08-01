function apt_update() {
  if [[ "${module_state[apt_updated]}" != 'true' ]]; then
    echo "Updating apt packages..."
    sudo apt update
    module_state[apt_updated]='true' 
  fi
}

function apt_install() {
  apt_update
  echo "Installing apt packages: ${@}..."
  sudo apt install -y "$@"
}

function install_apt() {
  true
}
