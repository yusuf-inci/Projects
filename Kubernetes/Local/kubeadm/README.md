# Kubernetes Cluster with Vagrant

This project provides a simple way to create a Kubernetes cluster with one control plane node and multiple worker nodes using Vagrant.

## Prerequisites

To use this project, you will need to have the following software installed on your machine:

- Vagrant
- VirtualBox

## Usage

1. Clone this repository to your local machine.
2. Navigate to the project directory and run `vagrant up` command to create the virtual machines.
3. Once the virtual machines are created, you can SSH into the control plane node by running `vagrant ssh control-plane1`.
4. You can verify the Kubernetes cluster is running by running the command `kubectl get nodes` on the control plane node.
5. To destroy the virtual machines and remove all resources created by this project, run the `vagrant destroy` command.

## Vagrantfile

The Vagrantfile in this project defines the configuration for the virtual machines that will be created.

The file specifies the following:

- The base image for the virtual machines (`ubuntu/bionic64`)
- The number of nodes for each role (control plane or worker)
- The private network configuration for inter-node communication
- The hostname and provider-specific options for each virtual machine
- The synced folder between the host machine and the guest machine
- The provisioning script that will be run on each virtual machine

## Provisioning Script

The provisioning script (`controlplane.sh` and `worker.sh`) installs the necessary software to create a Kubernetes cluster.

The script performs the following steps:

- Enables and configures the `br_netfilter` kernel module.
- Installs Docker CE and sets up the Docker daemon.
- Installs `kubeadm`, `kubelet`, and `kubectl`.

## License

This project is licensed under the MIT License.
