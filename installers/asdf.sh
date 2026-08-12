readonly ASDF_VERSIONS_FILE='.tool-versions'

function install_asdf() {
  require git gh shell
  mkdir -p ~/.asdf
  gh_download_latest_release "asdf-vm/asdf" "asdf-*-linux-amd64.tar.gz" "/tmp/asdf.tar.gz" | tar -xz -C ~/.asdf
  shell_append asdf "PATH=\$PATH:\$HOME/.asdf:\$HOME/.asdf/shims"
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
  local -a current
  current=($(asdf current --no-header "$plugin" 2>/dev/null))

  if [ "${current[3]}" == "true" ]; then
    echo "installed"
  elif [ "${current[1]:0:1}" == "_" ]; then
    echo "no"
  else
    echo "yes"
  fi
}

function asdf_install() {
  local -r plugin="${1?Missing plugin name}"
  local version="${2}"

  asdf_plugin_add "$plugin"

  if [ -z "$version" ]; then
    local has_version
    has_version=$(_asdf_has_version "$plugin")

    if [ "$has_version" == "installed" ]; then
      info "$plugin is already installed and set to the correct version"
      return 0
    elif [ "$has_version" == "no" ]; then
      # Default to latest version
      version="latest"
    fi
  fi

  echo "Installing $plugin $version..."
  if [ -n "$version" ]; then
    asdf install "$plugin" "$version"
    if [ "$version" == "latest" ]; then
      asdf set -u "$plugin" "$version"
    fi
  else
    asdf install "$plugin"
  fi
}
