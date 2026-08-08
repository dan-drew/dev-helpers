function __dev_helpers_help() {
  if ! [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat > /dev/null
    return 0
  fi

  cat
  return 1
}

function hg() {
  history | grep "$1" | uniq -f 1 | tail -n10
}
