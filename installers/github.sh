require apt

function gh_logged_in() {
  gh auth status &> /dev/null
}

function gh_latest_release() {
  local -r repo="${1?Missing repository name (e.g., owner/repo)}"
  gh release list --repo "$repo" --limit 100 --json name,isLatest,tagName --jq '.[] | select(.isLatest == true) | .tagName'
}

function gh_download_latest_release() {
  local -r repo="${1?Missing repository name (e.g., owner/repo)}"
  local -r asset_name="${2?Missing asset name (e.g., mytool-linux-amd64.tar.gz)}"

  local latest_release
  latest_release=$(gh_latest_release "$repo")
  if [[ -z "$latest_release" ]]; then
    error "No releases found for $repo"
  fi

  gh release download "$latest_release" --repo "$repo" --pattern "$asset_name" --output -
}

function install_github() {
  if ! has_command gh; then
    if $is_linux; then
      apt_install gh
    elif $is_apple; then
      brew install gh
    fi
  fi

  if ! gh_logged_in; then
    echo "Please log in to GitHub CLI (gh) to continue."
    gh auth login
  fi
}
