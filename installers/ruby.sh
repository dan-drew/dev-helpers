readonly _RUBY_DEPENDENCIES=(
  build-essential
  libffi-dev
  libz-dev
  libssl-dev
  libyaml-dev
)


function install_ruby() {
  require asdf

  if ! asdf_is_installed ruby; then
    require apt
    apt_install "${_RUBY_DEPENDENCIES[@]}"
    asdf_install ruby $1
  fi
}
