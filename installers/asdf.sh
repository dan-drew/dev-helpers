readonly ASDF_VERSIONS_FILE='.tool-versions'

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

function _asdf_has_version() {
  local -r plugin="${1?Missing plugin name}"

  read -r p1 pv pp pi <<< "$(asdf current --no-header python 2>/dev/null)"

  if [ "$pi" == "true" ]; then
    # Yes and already installed
    return 2
  elif [ "${pv:0:1}" != "_" ]; then
    # No and not defined
    return 0
  else
    # Yes and not installed
    return 1
  fi
}

function asdf_install() {
  local -r plugin="${1?Missing plugin name}"
  local version="${2}"

  asdf_plugin_add "$plugin"

  if [ -z "$version" ]; then
    local has_version=

    if ! ( _asdf_has_version "$plugin" && has_version=$? ); then
      version="latest"
    elif [ $has_version -eq 2 ]; then
      info "$plugin is already installed and set to the correct version"
      return 0
    fi
  fi

  echo "Installing $plugin $version..."
  if [ -n "$version" ]; then
    asdf install "$plugin" "$version"
    asdf set -u "$plugin" "$version"
  else
    asdf install "$plugin"
  fi
}
