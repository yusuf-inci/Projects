# GitOps Project

## Project Architecture  
This entire project revolves around GitHub, where we'll have two git repositories, 
- one for Terraform code, `https://github.com/hkhcoder/iac-vprofile.git`, has two branch: main and stage, in real time main branch is locked. When staging branch code is validated successfully, the staging branch will be merged to the main branch. So a pull request will get created. This pull request will be validated or checked by someone who is in charge, or the owner of the main branch who can approve the changes to be applied. When the main branch gets the new change, it will be detected by the workflow. And the same code which is in the main branch now will be applied. At the infrastructure level.  
In this case the infrastructure is AWS. We have a complete infrastructure of VPC. On top of that we have Amazon Elastic Kubernetes Service. So when our Terraform code will be applied for the first time, it is going to create the VPC, create the ECS cluster, and whenever you make any change to the Terraform code, the same flow will repeat. The staging branch will be tested, pull request will be created. It will be approved. Then the main branch will be merged with the staging branch, and then the changes will be applied from the main branch against the infrastructure. So this will conclude or complete your workflow for the infrastructure code. So in GitHub these things are called as workflow. You can call it pipeline or CI CD for infrastructure changes.
- one for application code, Docker file and Kubernetes definition files `https://github.com/hkhcoder/vprofile-action.git`. This is to apply any change at the application level. So we will have a workflow which is going to fetch the code, build the code, test the code and deploy the code. We will be having Maven. Maven with checkstyle and sonar CLI. Sonar code analysis CLI, which is going to test our source code and validate it with sonar cloud quality gates. If everything checks out fine. Then it is going to build Docker images and upload it to Amazon ECR, the Docker registry. After this, we are going to have helm charts, which will be the bundle of our Kubernetes definition file. It will also have a variable which mentions the tag name for the image, the image name, and the tag name. Basically from where to fetch the image and what version of the image. To fetch this, we are going to pass it in the workflow automatically. This will be the same tag we use to build the docker image. Same tag will be passed to the helm charts, and the helm charts gets executed on our cluster. Now here the Kubernetes cluster is going to detect the change of the image tag. It's going to fetch the image from ECR and run your application. So that is the entire architecture of this project.  
Two git repositories, two workflows. One to apply infrastructure changes and one to apply application changes. Both repositories have separate workflows which will detect the changes in the code and apply it on the infrastructure and application.

## Setup Github repo:
- go to github.com. Login to your account. go to `https://github.com/hkhcoder/iac-vprofile.git` this repository will have the source code for the Terraform, fork this repository into our GitHub account. So there are two branches over here main and stage.
- fork one more repository.`https://github.com/hkhcoder/vprofile-action.git`
- Set the SSH authentication: open terminal then `cd ~./.ssh`, `ssh-keygen`, keyname: `actions` then grab public key content, Go to your GitHub account, settings, SSH and GPG keys, new ssh key, name: actionskey, paste the content, Add ssh key. back to terminal and run `export GIT_SSH_COMMAND="ssh -i ~/.ssh/actions"`
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



- Write the workflows.
- Integrate Visual Studio Code with GitHub.


