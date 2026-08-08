readonly __TERRAGRUNT_DIR="${HOME}/.terragrunt/bin"

function install_terragrunt() {
  if ! [ -f "${__TERRAGRUNT_DIR}/terragrunt" ]; then
    require terraform shell
    curl -sSfL --proto '=https' --tlsv1.2 https://terragrunt.com/install | bash
  fi

  require shell
  shell_append terragrunt "export PATH=${__TERRAGRUNT_DIR}:\$PATH"
}
