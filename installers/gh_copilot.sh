function install_gh_copilot() {
  if ! has_command copilot; then
    if ! has_command node; then
      require node
    fi

    npm install -g @github/copilot
  fi
}
