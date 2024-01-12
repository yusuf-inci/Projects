#!/bin/bash

lsmod | grep br_netfilter
sudo modprobe br_netfilter
lsmod | grep br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# (Install Docker CE)
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update && sudo apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg
# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install the latest version
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Set up the Docker daemon
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

sleep 30

# Install kubeadm, kubelet, and kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
# deb https://apt.kubernetes.io/ kubernetes-xenial main
# EOF

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
# sudo mkdir -m 755 /etc/apt/keyring
### sudo apt-get install -y kubelet=<desired_version> kubeadm=<desired_version> kubectl=<desired_version>
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl stop ufw
sudo systemctl disable ufw

# Check if the 'cri' plugin is disabled
if grep -q '^disabled_plugins = \["cri"\]' /etc/containerd/config.toml; then
  # Replace 'disabled_plugins' with 'enabled_plugins'
  sed -i 's/disabled_plugins/enabled_plugins/' /etc/containerd/config.toml

  # Add the 'cri' plugin configuration
  cat <<EOF >> /etc/containerd/config.toml

[plugins."io.containerd.grpc.v1.cri".containerd]
  endpoint = "unix:///var/run/containerd/containerd.sock"
EOF

  # # Add the 'cri' plugin configuration for kubernetes v1.29
  # cat <<EOF >> /etc/containerd/config.toml
  # [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]

  # [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  # SystemdCgroup = true
# EOF

  # Restart containerd to apply the changes
  sudo systemctl restart containerd
fi

sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.28.11 > /tmp/kubeadm_out.log
sleep 360

# Apply Weave Net DaemonSet
# kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# configure kube config
sudo mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant.vagrant /home/vagrant/.kube
sudo mkdir -p /root/.kube
sudo cp -f /etc/kubernetes/admin.conf /root/.kube/config
sudo chown -R root.root /root/.kube
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"




# # Update the sandbox image
# kubectl set image daemonset.apps/weave-net weave=registry.k8s.io/pause:3.9 --namespace=kube-system

sleep 60

sudo cat /tmp/kubeadm_out.log | grep -A1 'kubeadm join' > /vagrant/cltjoincommand.sh
sudo chmod +x /vagrant/cltjoincommand.sh

# Install the Kubernetes dashboard
sudo su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml"





# #!/bin/bash

# lsmod | grep br_netfilter
# sudo modprobe br_netfilter
# lsmod | grep br_netfilter
# cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF
# sudo sysctl --system

#   # (Install Docker CE)
#   ## Set up the repository:
#   ### Install packages to allow apt to use a repository over HTTPS
#   sudo apt-get update && sudo apt-get install -y \
#     apt-transport-https ca-certificates curl software-properties-common gnupg
#   # Add Docker's official GPG key:
#   sudo install -m 0755 -d /etc/apt/keyrings
#   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#   sudo chmod a+r /etc/apt/keyrings/docker.gpg

#   # set up the repository

#   echo \
#   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#   # install the latest version
#   sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#   # Set up the Docker daemon
#   sudo tee /etc/docker/daemon.json > /dev/null <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2"
# }
# EOF
#   sudo mkdir -p /etc/systemd/system/docker.service.d

#   # Restart Docker
#   sudo systemctl daemon-reload
#   sudo systemctl restart docker
#   sudo systemctl enable docker

#   sleep 30

#  # Install kubeadm, kubelet, and kubectl

#   sudo apt-get update && sudo apt-get install -y apt-transport-https curl
#   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#   cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
#   deb https://apt.kubernetes.io/ kubernetes-xenial main
# EOF
#   sudo apt-get update
#   sudo apt-get install -y kubelet kubeadm kubectl
#   sudo apt-mark hold kubelet kubeadm kubectl
#   sudo systemctl stop ufw
#   sudo systemctl disable ufw

# # Check if the 'cri' plugin is disabled
# if grep -q '^disabled_plugins = \["cri"\]' /etc/containerd/config.toml; then
#   # Replace 'disabled_plugins' with 'enabled_plugins'
#   sed -i 's/disabled_plugins/enabled_plugins/' /etc/containerd/config.toml

#   # Add the 'cri' plugin configuration
#   cat <<EOF >> /etc/containerd/config.toml

# [plugins."io.containerd.grpc.v1.cri".containerd]
#   endpoint = "unix:///var/run/containerd/containerd.sock"
# EOF

#   # Restart containerd to apply the changes
#   sudo systemctl restart containerd
# fi


# sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.28.11 > /tmp/kubeadm_out.log
# sleep 360


# # configure kube config
# sudo mkdir -p /home/vagrant/.kube
# sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
# sudo chown -R vagrant.vagrant /home/vagrant/.kube
# sudo mkdir -p /root/.kube
# sudo cp -f /etc/kubernetes/admin.conf /root/.kube/config
# sudo chown -R root.root /root/.kube
# mkdir -p $HOME/.kube
# sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# sudo kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# sleep 60


# sudo cat /tmp/kubeadm_out.log | grep -A1 'kubeadm join' > /vagrant/cltjoincommand.sh
# sudo chmod +x /vagrant/cltjoincommand.sh

# # Install the Kubernetes dashboard
# sudo su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml"
