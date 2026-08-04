function install_terragrunt() {
  require terraform

  curl -sSfL --proto '=https' --tlsv1.2 https://terragrunt.com/install | bash
  bash_append "terragrunt" "export PATH=${HOME}/.terragrunt/bin:\$PATH"
}
