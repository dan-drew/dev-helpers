function install_terraform() {
  require asdf apt
  apt_install unzip
  asdf_install terraform "${1:-latest}"
}
