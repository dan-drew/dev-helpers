readonly -A __DEV_HELPERS_PRINT_LEVELS=(
  [debug]='\033[34m'
  [info]=''
  [success]='\033[32m\033[1m'
  [warn]='\033[1m\033[33m'
  [error]='\033[1m\033[31m'
)

function __dev_helpers_help() {
  if ! [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat > /dev/null
    return 0
  fi

  cat
  return 1
}

function __dev_helpers_print() {
  local -r level=${1:?"Missing level argument"}
  
  local EOL="\n"
  if [ "$2" == "-n" ]; then
    EOL=""
    shift
  fi

  local -r message=${2:?"Missing message argument"}
  local -r color=${__DEV_HELPERS_PRINT_LEVELS[$level]?"Unknown level: $level"}

  shift 2
  printf "${color}${message}\033[0m${EOL}" "$@" >&2
}

function __dh_error() {
  __dev_helpers_print error "$@"
}

function __dh_warn() {
  __dev_helpers_print warn "$@"
}

function __dh_info() {
  __dev_helpers_print info "$@"
}

function __dh_debug() {
  __dev_helpers_print debug "$@"
}

function __dh_success() {
  __dev_helpers_print success "$@"
}

function hg() {
  history | grep "$1" | uniq -f 1 | tail -n10
}
