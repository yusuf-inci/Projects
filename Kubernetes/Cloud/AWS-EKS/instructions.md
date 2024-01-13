# AWS EKS

## Prerequisites
- region: us-east-2
- create key pair name: `vprofile-eks-key`
- create iam user name: `eksadmin`, attach policy:  administrator access, download .csv store safely,  
- `vagrant up`
- `vagrant ssh`
- check tools: `aws --version`, `eksctl version`, `kubectl version` 
- aws configure, give eksadmin credentials.

## Create cluster
- go to vagrant directory: `cd vagrant`, 
- configure `eks-cluster-setup.sh` according to your needs
- to create the Kubernetes cluster on EKS run the script: `./eks-cluster-setup.sh`
- go to AWS console 
- check EKS
- check VPC, Should see Six subnets. Three public and three private.
- check the NAT gateway. So it's going to wait until this VPC up with the NAT Gateway, the VPC stable, then it's going to start launching cluster.
- check EKS cluster: vprofile-eks-cluster, So this acts like your master notes. You don't have a master node. the worker node group will be under compute. two compute nodes This is all done through a cloud formation template. also you can check cloud formation. 
- back to vm and check the cube config file. `cat /home/vagrant/.kube/config`
- run `kubectl get nodes`, So you should see the two worker notes. You'll not see the master node, and then you can run all your test. You can launch pod deployment services, any other object on the Kubernetes cluster. Kubernetes cluster up and running.

## Clean Up
- `kubectl delete cluster vprofile-eks-cluster` So wait until it's completely deleted. If you get any error, you can very easily go to cloud formation templates and delete the stacks.
