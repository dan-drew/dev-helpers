readonly _PY_DEPENDENCIES=(
  build-essential
  libz-dev
  libreadline-dev
  libncursesw5-dev
  libssl-dev
  libgdbm-dev
  libsqlite3-dev
  libbz2-dev
  libffi-dev
  zlib1g-dev
  libc6-dev
  liblzma-dev
  libgdbm-compat-dev
)

function py_install() {
  pip install "$@"
}

function install_python() {
  require asdf apt
  apt_install "${_PY_DEPENDENCIES[@]}"
  asdf_install python $1
  py_install --upgrade pip
  py_install uv
}
