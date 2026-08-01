function install_chrome() {
  # download chrome https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /tmp/chrome.deb
  # echo "Installing chrome..."
  # if ! sudo dpkg -i /tmp/chrome.deb; then
  #   sudo apt -y -f install
  # fi

  local -r chrome_path=$( which google-chrome )
  if [[ -n "${chrome-path}" ]]; then
    append_profile "export CHROME_BIN=${chrome_path}"
  fi
}
