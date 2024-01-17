# Java App Deployment on Kubernetes Cluster on AWS with Kops
## Prerequisites
- Domain for Kubernetes DNS records.
- Linux VM, in this case EC2 instance. to launch the Kubernetes cluster with kops. to install cops,kubectl, ssh keys, awscli 
- S3 bucket, 
- an Iam user for our AWS CLI.
- Route 53 hosted zone, which will be our subdomain.
- Domain Registrar in this case GoDaddy 

1. Linux VM: EC2 service, launch an instance with ubuntu Ami, name: kops, Ubuntu 22.04, t2.micro, create a new key pair, name: kops-key, create. Network settings, edit, create security group, kops-sg, port 22 allowed from my IP, launch instance.
2. S3 bucket: Create a bucket, region: us-east-1, name: `vprofile55-kops-state` Create Bucket.
3. IAM User: name: kops-admin, Attach policies, select administrator access policy, create.  
Click on this user, security credentials, generate the access key, Create access key, download the CSV file.
4. Route 53:create a hosted zone, domain name: kubepro.devopstr.info, create hosted zone. we should get the server's URL. add this entry in our domain registrar.
5. GoDaddy: add four ns record for four ns server. Now your four records  for subdomain that points to the name server of Amazon Route 53.

### Create cluster 

- log into EC2 instance
- generate the SSH key which will be used by the cops. `ssh-keygen`
- install and configure aws cli: `sudo apt update`, `sudo apt install awscli -y`, `aws --version`, `aws configure`
give the access key and secret key, which you have downloaded. Region: `us-east-1`, `cat ~/.aws/config`, `cat ~/.aws/credentials`.
- install and setup kubectl: download Kubectl `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`we have a kubectl binary. 
give it executable permission `chmod +x ./kubectl`, move it to usr local bin: `sudo mv kubectl /usr/local/bin/`, `kubectl --help`,  kubectl is installed.
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

## Create new repo on github
- to keep all kubernetes definition file
- name: `kubevpro`, clone localy with IDE in this case Visual Studio Code, install kubernetes plugin.

## Create a volume for DB pod
- to store the MySQL data which gets stored in var lib mySQL into EBS volume.
- log into kops EC2 instance and create an EBS volume.  
`aws ec2 create-volume --availability-zone=us-east-1a --size=3 --volume-type=gp2`, grab volume id
- be sure volume and DB pod are same availability zone. Now we have to make sure when we run our DB pod it should be running on a node which is in the same zone, same availability zone, and we can make that through node selector option in our definition file. Node selector works with labels, so we're going to create our own label.
- `kubectl get nodes --show-labels`
- create own label: `kubectl get nodes`, check which node is stands on us-east-1a, `kubectl describe node <name of node> | grep us-east-1`, So one node should be good to run our DB pod, but label both the nodes.`kubectl label nodes <name of node> zone=us-east-1a`. for other node `kubectl label nodes <name of node> zone=us-east-1b`.
- give a tag to volume:  
go to AWS console, EBS Volumes, find volume you can match it with the volume id, Tags, Add/Edit Tags, Create Tag, Key: `KubernetesCluster`, Value: (cluster name) `kubevpro.devopstr.info`, Save.


## Docker images
- use following images
`docker pull devopstr55/vprofileapp`
`docker pull devopstr55/vprofiledb`

## Kube secret for password
- use this repo: `https://github.com/yusuf-inci/kubevpro.git` 
- start writing definition file with encoding the password ( db and rabbitmq paswords )
- create file name: `app-secret.yaml`
- encode the values of passwords and then mention it in the file. goto application properties file, grab the passwords and encode them. (db-pass: and rmq-pass)
- to encode `echo -n "<password>" | base64`
- after finish writing save, commit and push it.
- Before we write other definition file, run a test. log into kops EC2 instances, clone repo `https://github.com/yusuf-inci/kubevpro.git`, get into kubevpro, you should have the secret here.
- create it, `kubectl create -f app-secret.yaml`, `kubectl get secret`, To see the detail information `kubectl describe secret` 

- Database definition file: name: `vprodbdep.yaml`. to get labels on cluster: `kubectl get nodes --show-labels`
- after finish writing save,be sure ADD <ebs volume id>, commit and push it.
- back into kops EC2 instances, get into kubevpro, pull the code `git pull`,
- test it, `kubectl create -f vprodbdep.yaml`, `kubectl get deploy`, `kubectl get pod`, To see the detail information `kubectl describe pod <pod name>` 
- create other definition and service files

## Provision Stack on K8s Cluster
- back into kops EC2 instances, get into kubevpro, pull the code `git pull`, check the files then create all definition files in this folder: `kubectl create -f .`, `kubectl get deploy`, `kubectl get pod`, `kubectl get svc`, grab load balancer endpoint, and test it via browser. 

## URL for website
- Grab Load balancer endpoint from cluster `kubectl get svc`, We have an end point and we can also put this into our GoDaddy or we can also use a Route 53.
- go to Route 53, hosted zone, create record, Simple record, name: blog, endpoint: select load balancer, us-east-1, select elb, Define simple record, create record, test it with URL, 

## Clean up
- to delete your application, back into kops EC2 instances, get into kubevpro, `kubectl delete -f .`
- delete cluster: `kops delete cluster --name kubevpro.devopstr.info --state=s3://vprofile55-kops-state --yes`
