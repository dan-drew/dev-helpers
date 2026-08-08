function install_terraform() {
  if ! test_command unzip --help; then
    require apt
    apt_install unzip
  fi

  require asdf
  asdf_install terraform "${1:-latest}"

  require shell
  shell_initializer 20_terraform_prompt terraform_prompt.sh
  shell_initializer terraform_aliases
}
