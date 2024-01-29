# GitOps Project

## Project Architecture  
This entire project revolves around GitHub, where we'll have two git repositories, 
- one for Terraform code, `https://github.com/yusuf-inci/iac-vprofile.git`, has two branch: main and stage, in real time main branch is locked. When staging branch code is validated successfully, the staging branch will be merged to the main branch. So a pull request will get created. This pull request will be validated or checked by someone who is in charge, or the owner of the main branch who can approve the changes to be applied. When the main branch gets the new change, it will be detected by the workflow. And the same code which is in the main branch now will be applied. At the infrastructure level.  
In this case the infrastructure is AWS. We have a complete infrastructure of VPC. On top of that we have Amazon Elastic Kubernetes Service. So when our Terraform code will be applied for the first time, it is going to create the VPC, create the ECS cluster, and whenever you make any change to the Terraform code, the same flow will repeat. The staging branch will be tested, pull request will be created. It will be approved. Then the main branch will be merged with the staging branch, and then the changes will be applied from the main branch against the infrastructure. So this will conclude or complete your workflow for the infrastructure code. So in GitHub these things are called as workflow. You can call it pipeline or CI CD for infrastructure changes.
- one for application code, Docker file and Kubernetes definition files `https://github.com/yusuf-inci/vprofile-action.git`. This is to apply any change at the application level. So we will have a workflow which is going to fetch the code, build the code, test the code and deploy the code. We will be having Maven. Maven with checkstyle and sonar CLI. Sonar code analysis CLI, which is going to test our source code and validate it with sonar cloud quality gates. If everything checks out fine. Then it is going to build Docker images and upload it to Amazon ECR, the Docker registry. After this, we are going to have helm charts, which will be the bundle of our Kubernetes definition file. It will also have a variable which mentions the tag name for the image, the image name, and the tag name. Basically from where to fetch the image and what version of the image. To fetch this, we are going to pass it in the workflow automatically. This will be the same tag we use to build the docker image. Same tag will be passed to the helm charts, and the helm charts gets executed on our cluster. Now here the Kubernetes cluster is going to detect the change of the image tag. It's going to fetch the image from ECR and run your application.  
Two git repositories, two workflows. One to apply infrastructure changes and one to apply application changes. Both repositories have separate workflows which will detect the changes in the code and apply it on the infrastructure and application.

## Setup Github repo:
- go to github.com. Login to your account. go to `https://github.com/hkhcoder/iac-vprofile.git` this repository will have the source code for the Terraform, fork this repository into our GitHub account. So there are two branches over here main and stage.
- fork one more repository.`https://github.com/hkhcoder/vprofile-action.git`
- Set the SSH authentication: open terminal then `cd ~/.ssh`, `ssh-keygen`, keyname: `actions` then grab public key content, Go to your GitHub account, settings, SSH and GPG keys, new ssh key, name: actionskey, paste the content, Add ssh key. back to terminal and run `export GIT_SSH_COMMAND="ssh -i ~/.ssh/actions"`
Create a folder where we're going to clone this repository. go into that path, clone your iac-vprofile and vprofile-action repo with ssh path. 
- we also need to make sure that when we use the repository it should use the SSH key that we have created.
So go to the repository folder and run `git config core.sshCommand "ssh -i ~/.ssh/actions -F /dev/null"` for each repo.
- back to this folder where we have cloned both the repository, run `cp -r iac-vprofile main-iac`, `cd iac-vprofile`, `git branch -a`, `git checkout stage` keep this repo in stage branch. We are going to make the code changes in the staging branch only. We are going to test it. If it works fine then we will merge it with the main branch. When we merge it in the main branch, that's when it's going to actually apply.

## AWS Configuration
- Create Access Keys, create user with administrator credential and Create Access Keys then enter keys to github repo secrets. Store these information in Github Secret
- open both the repository iac-vprofile and vprofile-action from GitHub. Go to settings, Secrets, actions, new repository secret, name: `AWS_ACCESS_KEY_ID` secret: paste Access key, add secret. again new repository secret, name: `AWS_SECRET_ACCESS_KEY` secret: paste Secret access key, add secret. Repeat same steps for other repository.
- Create S3 Bucket for terraform state: in this case region: us-east-2 name: `vprofile55actions`, copy the bucket name and add iac-vprofile repository secret, name: `BUCKET_TF_STATE` secret: paste the bucket name
- Create ECR Repository, name: `vprofile55`, grab the URI, add vprofile-action repository secret, name: `REGISTRY` secret: paste the URI without end of uri(ex: 111111111.dkr.ecr.us-east-2.amazonaws.com)

## Terraform files
- The Terraform code will set up the VPC infrastructure and ECS cluster.
- all this Terraform code will get executed from GitHub actions.
- used two modules VPC and EKS modules.
- Always be in the staging branch in the VS code. Do not make change in the main branch.
- Configure region and eks cluster name in variable file.
- Configure terraform state with s3 backend in terraform.tf file. if this backend is not mentioned, then when you run the Terraform init terraform apply.It's going to create this file locally on that system where it is created on the same folder where you executed the terraform apply command. Now somebody else in your team using the same Terraform code executes that code.It will not have that terraform.tf state file. And this will try to create that entire infrastructure once again or make a different change which you don't need. So there should be a centralized Terraform state file. And in GitOps it's very essential because this is going to run it on the tool. Like in this case we are going to run it on GitHub actions. So the workflow will create a container, run Terraform on that, and that container will be deleted after the workflow is completed. So you will lose the terraform state file. There will be infrastructure created, but then you run the code again. Again it will create the infrastructure to try to create and it will fail. A lot of issues will come in.

## Staging workflow for terraform code
- Every repository will have its own actions. Write code for workflow. Workflow means pipeline in other tools. We are not going to create any workflow from github web page manually. Once write the workflow code and when we push the code, the workflow will be automatically created.
- testing: make any changes in the file in terraform folders commit and push it. Then check github action on browser.
- this is all on the staging branch but in real time there will be a staging environment, a testing environment where this code will be applied and tested.
- We're going to apply that changes when we merge with the main branch. Then changes will be applied to the actual account.

## Main workflow for terraform code

- add steps to apply the Terraform code in the workflow only if there is the change on the main branch. If there is any push on the main branch, then only execute the command Terraform apply.
- if you want to make any change to infrastructure, simply commit it in the staging branch. merge it to the main branch. main branch is going to apply the changes.In staging branch We are just testing it. We just run Terraform plan, but 
- in real time. There should be a test environment where it applies all the changes. If those all those works fine then a pull request will be created on GitHub. And the owner of the main branch can approve the pull request if everything gets validated properly. If he or she finds the pull request right reasonable, they will allow the merge. And that should trigger workflow again. And all the changes from the main branch will be applied by the GitHub actions on the cloud.

## Workflow for vprofile app code
- We have a separate git repository for application code. So we'll create a workflow which is going to fetch the code. Test our code by using Maven, Checkstyle and sonar analysis. Then build the Docker image, upload it to Amazon ECR. Then we are going to build the helm charts, which when we deploy is going to fetch that latest image from ECR and run our application.
- go to sonar cloud, create new organization project and token and store it on GitHub secrets. Also create new quality gate and assign it to project.
- we created the ingress controller in the infrastructure workflow. When we create the cluster we created nginx ingress controller. So we can create the ingress rules. update host in the vproingress.yaml with your domain `vprofile.devopstr.info`
- create the workflow. go to github actions and run workflow manually. if you get error then fix it  

## Build the Docker image from the source code and deploy it to the ECR
- our source code has tested. Next step is build the Docker image and upload it to ECR.
- create another job. it should run after the testing job complete. give needs option otherwise it will execute Parallely with testing job. then check out the source code, To build and upload the image to ECR use ready made actions Docker ECR by Apple boy. 
- save, commit and push. run workflow. After completed successfully. Check ECR  repository.

# Deploy to EKS
- deploy Kubernetes definition files.
- In order to pass the image in the app deployment file (vproappdep.yml) regularly in the workflow with the latest tag, define a variable. create helm charts where we are going to keep all these definition files and mention variables in helm charts. When we apply the helm charts, and those values will be replaced by the variable that we are going to mention over here.
- Install Helm on ubuntu From the Binary Releases `https://helm.sh/docs/intro/install/` 
Download your desired version, Unpack it `tar -zxvf helm-v3.0.0-linux-amd64.tar.gz`, Find the helm binary in the unpacked directory, and move it to its desired destination `mv linux-amd64/helm /usr/local/bin/helm`
- goto your project directory on local machine `cd ~/codes/vprofile-action/`, run `helm create vprofilecharts` It is going to create a folder called Helm Charts and the complete package or complete suit of your application is called as charts, create a folder name it helm and move vprofile charts to helm folder. `ls`, `mkdir helm`, 
`mv vprofilecharts helm/`, Remove all default templates and copy vprofile charts to templates folder `ls helm/vprofilecharts/templates/`, `rm -rf helm/vprofilecharts/templates/*`, `ls`, `cp kubernetes/vpro-app/* helm/vprofilecharts/templates/`, `ls helm/vprofilecharts/templates/`
- goto vscode, `/vprofile-action/helm/vprofilecharts/templates/vproappdep.yml` change the image `{{ .Values.appimage}}:{{ .Values.apptag}}` Now we can mention the values of any variable in values.yaml file. But we are not going to do that. We are going to pass it when we run the helm command through the workflow. Back to workflow and add last job.
- Create `DeploytoEKS` job. So before we deploy our helm charts, we need to have two more steps. One is to generate the kube config file by running AWS command, and the second storing the registry credentials. The Docker registry credentials in Kubernetes. So when the helm charts executes and Kubernetes tries to fetch the image from ECR, it has the authentication. commit, push and run workflow.
- So go to the load balancers in the same region. find the load balancer that was created by the nginx ingress controller. Copy the DNS name and go to your domain. add a CNAME record. You might need to wait a little longer also. go to browser and test the app.

## Clean Up
1. Remove ingress controller which should delete the load balancer that it created. goto iam, user which you created go to its security credentials and create new access keys CLI.
- go to your local machine. configure aws cli with new access keys, 
- remove existing kube config file `rm -rf ~/.kube/config`, get kube config file `aws eks update-kubeconfig --region us-east-2 --name vprofile-eks`, `kubectl get nodes`, in terminal go to your `iac-vprofile` repository and `cat .github/workflows/terraform.yml`, grad the url ` kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/aws/deploy.yaml` So this will read the file and delete the ingress controller that was created, including the load balancer.
- Okay, that got deleted helm list and this is not mandatory. Once delete the Kubernetes cluster everything will be gone with it. But you can uninstall your release by giving like this helm uninstall and the release name. `helm list`, `helm uninstall vprofile-stack`
- cat to the Terraform workflow file once again. `cat .github/workflows/terraform.yml`, in the terraform folder run following command, before do this it's safe that you download this terraform.tf state file locally. `terraform init -backend-config="bucket=<bucket name(vprofile55)>"` Then run `terraform destroy` That is going to find all the services on that was created and then deleted. everything will be destroyed with this command.
This will take some time to destroy.