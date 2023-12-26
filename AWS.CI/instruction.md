# AWS Services
- Code Commit 
- Code Artifact (Maven Repository for Dependincies)
- Code Build 
- Code Deploy
- Sonar Cloud
- Checkstyle
- Code Pipeline
- S3 (store artifact)


## Login AWS  
Region: us-east-1 (North Virginia)
## Code Commit
- Create codecommit repo:  
Create repository, name: vprofile-code-repo, create.  
- Create iam user with codecommit custom policies:  
Create user, name: vprofile-code-admin, Attach policy, create ploicy, select codecommit, check All CodeCommit actions, Add ARNs, Resource in, check this account, region:us-east-1, repository name: vprofile-code-repo, add ARNs, next, policy name: vprofile-repo-fullAccess, create policy, back to iam policy tab and refresh, find your policy and check it, next, create user.  
Goto newly created user and create access key, cli, download csv file. 
Configure AWS CLI with this users crenditials,   
- SSH auth to CodeCommit repo:  
Generate ssh keys locally & Exchange keys with iam user: ssh-keygen, store and name it: ~/.ssh/vpro-codecommit_rsa, grab public key, Upload SSH public key to vprofile-code-admin user credentials, configure ~/.ssh/config with this user crenditials, you can grab template. `https://github.com/hkhcoder/vprofile-project` branch: ci-aws, `aws-files/ssh_config_file`, test it via `ssh git-codecommit.us-east-1.amazonaws.com`. Any error use debug mode with `ssh -v git-codecommit.us-east-1.amazonaws.com` then check the log and fix the error.  
- Migrate vprofile-project repo from github to codecommit repo:  
Clone source code: `https://github.com/hkhcoder/vprofile-project.git`, change update remote origin to code commit url, `cat .git/config`, list all the remote branches: `git branch -a`, upload only ci-aws and cd-aws branch so checkout these branch to track remote branches: `git checkout ci-aws`, `git checkout cd-aws`, check it `git branch -a` you should see three branches.  
if you want to track all the remote branches you ca use following commands: `git branch -a | grep remotes`, to ignore head `git branch -a | grep remotes | grep HEAD | cut -d / -f3 > /tmp/branches` (-f3 linenumber of HEAD), `for i in `cat /tmp/branches` ; do echo $i ; done`, git checkout in loop: `for i in `cat /tmp/branches` ; do git checkout $i ; done`. remove origin in git config: `git remote rm origin`, check: `cat .git/config`, add our url to origin: goto code commit and grab SSH clone url then `git remote add origin <paste url>`, check:`cat .git/config`, to push all the branches to codecommit repo: `git push origin --all`, goto codecommit repo and check the codes also branches.   

## Code Artifact
- Create an iam user with code artifact acces
- İnstall AWS CLI & Configure
- Export auth token
- Update setting.xml in source code 
- Update pom.xml with repo details

## Sonar Cloud
- Create sonar cloud account
- Generate sonar token
- Create SSM parameters with sonar details
- Create Build project
- Update code build role to access SSM parameter store

## Create notifications for sns or slack

## Build Project 
- Update pom.xml with artifact version with timestamp
- Create variable in SSM ==> parameterstore
- Create build Project
- Update codebuild role to access SSMparameterstore

## Create Pipeline
- Code commit
- Test code
- Build
- Deploy to S3 bucket

# Test Pipeline

