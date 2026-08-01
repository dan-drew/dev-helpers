function install_asdf() {
  require git gh bash
  mkdir -p ~/.asdf
  gh_download_latest_release "asdf-vm/asdf" "asdf-*-linux-amd64.tar.gz" "/tmp/asdf.tar.gz" | tar -xz -C ~/.asdf
  bash_append asdf "PATH=\$PATH:\$HOME/.asdf:\$HOME/.asdf/shims"
}

function asdf_plugin_add() {
  local -r plugin="${1?Missing plugin name}"
  # local -r repo="${2?Missing plugin repository URL}"

  if ! asdf plugin list | grep -Fq "$plugin"; then
    asdf plugin add "$plugin" #"$repo"
  fi
}

function asdf_install() {
  local -r plugin="${1?Missing plugin name}"
  local -r version="${2:-latest}"

  asdf_plugin_add "$plugin"
  asdf install "$plugin" "$version"
  asdf set -u "$plugin" "$version"
}
