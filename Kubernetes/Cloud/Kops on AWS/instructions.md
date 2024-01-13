# Kubernetes Cluster on AWS with Kops
## Prerequisites
- Domain for Kubernetes DNS records.
- Linux VM, in this case EC2 instance. to launch the Kubernetes cluster with cops. to install cops,kubectl, ssh keys, awscli 
- S3 bucket, 
- an Iam user for our AWS CLI.
- Route 53 hosted zone, which will be our subdomain.
- Domain Registrar in this case GoDaddy 

1. Linux VM: EC2 service, launch an instance with ubuntu Ami, name: kops, Ubuntu 22.04, t2.micro, create a new key pair, name: kops-key, create. Network settings, edit, create security group, kops-sg, port 22 allowed from my IP, launch instance.
2. S3 bucket: Create a bucket, region: us-east-1, name: vprofile-kops-state Create Bucket.
3. IAM User: name: kops-admin, Attach policies, select administrator access policy, create.  
Click on this user, security credentials, generate the access key, Create access key, download the CSV file.
4. Route 53:create a hosted zone, domain name: kubepro.devopstr.info, create hosted zone. we should get the server's URL. add this entry in our domain registrar.
5. GoDaddy: add four ns record for four ns server. Now your four records over here for subdomain that points to the name server of Amazon Route 53.

## Create cluster 

- log into EC2 instance
- generate the SSH key which will be used by the cops. `ssh-keygen`
- install and configure aws cli: `sudo apt update`, `sudo apt install awscli -y`, `aws configure`
give the access key and secret key, which you have downloaded. Region: `us-east-1`
- install and setup kubectl: download Kubectl `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`we have a kubectl binary. 
give it executable permission `chmod +x ./kubectl`, move it to usr local bin: `sudo mv kubectl /usr/local/bin/`, `kubectl --help`, kubectl is installed.
- install is the kops, `wget https://github.com/kubernetes/kops/releases/download/v1.26.4/kops-linux-amd64`, `chmod +x kops-linux-amd64`, `sudo mv kops-linux-amd64 /usr/local/bin/kops`, `kops version`, verify domain: `nslookup -type=ns kubevpro.devopstr.info`.
- create configuration for the cluster and store it in the S3 bucket: 
<kops create cluster --name=kubevpro.devopstr.info \
--state=s3://vprofile55-kops-state --zones=us-east-1a,us-east-1b \
--node-count=2 --node-size=t3.small --master-size=t3.medium --dns-zone=kubevpro.devopstr.info \
--node-volume-size=8 --master-volume-size=8>  

- create cluster: <kops update cluster --name kubevpro.devopstr.info --state=s3://vprofile55-kops-state --yes --admin>
- verify & validate cluster: <kops validate cluster --name kubevpro.devopstr.info --state=s3://vprofile55-kops-state>
- `cat ~/.kube/config`, `kubectl get nodes`, can check that also AWS console
- list clusters with: `kops get cluster`
- edit this cluster with: kops edit cluster kubevpro.devopstr.info
- edit your node instance group: kops edit ig --name=kubevpro.devopstr.info nodes-us-east-1a
- edit your control-plane instance group: kops edit ig --name=kubevpro.devopstr.info 
control-plane-us-east-1a

## Clean Up
- delete cluster: <kops delete cluster --name kubevpro.devopstr.info --state=s3://vprofile55-kops-state 
--yes --admin>

