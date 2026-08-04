function install_docker() {
  require apt
  apt_install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  apt_update
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  local docker_group_changed=false

  if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker
    docker_group_changed=true
  fi

  if ! id -nG "$USER" | tr ' ' '\n' | grep -Fxq docker; then
    sudo usermod -aG docker "$USER"
    docker_group_changed=true
  fi

  if $docker_group_changed; then
    echo "Docker group updated. Please log out and back in for the change to take effect."
  fi

  if sudo systemctl is-active docker >/dev/null 2>&1; then
    echo "Docker is already running."
  else
    sudo systemctl start docker
  fi
}
