function apt_update() {
  sudo apt update
  module_state[apt_updated]='true' 
}

function apt_install() {
  if [[ "${module_state[apt_updated]}" != 'true' ]]; then
    apt_update
  fi
  echo "Installing apt packages: ${@}..."
  sudo apt install -y "$@"
}

function install_apt() {
  true
}
