#!/bin/bash

  # Docker Engine. Install using the apt repository
  ## Add Docker's official GPG key:
  
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
        
  # install the latest version
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # # Set up the Docker daemon
  # sudo tee /etc/docker/daemon.json > /dev/null <<EOF
# {
  # "exec-opts": ["native.cgroupdriver=systemd"],
  # "log-driver": "json-file",
  # "log-opts": {
    # "max-size": "100m"
  # },
  # "storage-driver": "overlay2"
# }
# EOF
  # sudo mkdir -p /etc/systemd/system/docker.service.d

  # Add user to the Docker group 
  sudo usermod -aG docker $USER

  # Restart Docker
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  sudo systemctl enable docker

  sleep 15

# Configure Docker to start on boot with systemd
  # sudo systemctl enable docker.service
  # sudo systemctl enable containerd.service
