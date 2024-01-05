# Continuous Integration on AWS
## AWS Services
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
Create user, name: vprofile-code-admin, Attach policy, create policy, select codecommit, check All CodeCommit actions, Add ARNs, Resource in, check this account, region:us-east-1, repository name: vprofile-code-repo, add ARNs, next, policy name: vprofile-repo-fullAccess, create policy, back to iam policy tab and refresh, find your policy and check it, next, create user.  
Goto newly created user and create access key, cli, download csv file. 
Configure AWS CLI with this users crenditials,   
- SSH auth to CodeCommit repo:  
Generate ssh keys locally & Exchange keys with iam user: ssh-keygen, store and name it: ~/.ssh/vpro-codecommit_rsa, grab public key, Upload SSH public key to vprofile-code-admin user credentials,  create config file and configure it ~/.ssh/config with this user crenditials, you can grab template. `https://github.com/hkhcoder/vprofile-project` branch: ci-aws, `aws-files/ssh_config_file`, make sure permission `chmod 600 config`, test it via `ssh git-codecommit.us-east-1.amazonaws.com`. Any error use debug mode with `ssh -v git-codecommit.us-east-1.amazonaws.com` then check the log and fix the error.  
- Migrate vprofile-project repo from github to codecommit repo:  
Clone source code: `https://github.com/hkhcoder/vprofile-project.git`, update remote origin to code commit url, `cat .git/config`, list all the remote branches: `git branch -a`, upload only ci-aws and cd-aws branch so checkout these branch to track remote branches: `git checkout ci-aws`, `git checkout cd-aws`, check it `git branch -a` you should see three branches.  
if you want to track all the remote branches you can use following commands: `git branch -a | grep remotes`, to ignore head `git branch -a | grep remotes | grep -v HEAD | cut -d / -f3 > /tmp/branches` or `git branch -a | grep -v HEAD | cut -d / -f3 > | grep -v master /tmp/branches` (-f3 third field of HEAD), `for i in `cat /tmp/branches` ; do echo $i ; done`, git checkout in loop: `for i in `cat /tmp/branches` ; do git checkout $i ; done`. remove origin in git config: `git remote rm origin`, check: `cat .git/config`, add our url to origin: goto code commit and grab SSH clone url then `git remote add origin <paste url>`, check:`cat .git/config`, to push all the branches to codecommit repo: `git push origin --all`, goto codecommit repo and check the codes also branches.   

## Code Artifact  
Used to store dependencies for the build tools like maven. ex: maven instead of downloading dependencies from the internet, it is going to download from AWS Code Artifact Repository. (like nexus).  
- Create Code Artifact Repository:  
Developer Tools ==> CodeArtifact ==> Create Repository, name: vprofile-maven-repo, Public upstream repository (where does code artifact get the dependencies) : maven-central-store, this account, domain name: devopstr, create repository.  
Go to code artifact repositories, you will see two repo: maven-central-store and vprofile-maven-repo click maven-central-store, view connection instruction, mac-linux, mvn, pull from your repository examine here. we are going to use here as a reference.  
- Create an iam user with code artifact access:  
Create IAM user, name `vprofile-cart-admin`, policy: `AWSCodeArtifactAdminAccess`, Download Credentias. Install AWS CLI & Configure it with this user.
- Export auth token: grab maven-central-store connection(step:3) Export commmand, `export CODEARTIFACT_AUTH_TOKEN=..........` and run it on terminal, see token `echo $CODEARTIFACT_AUTH_TOKEN`
- Update setting.xml in source code: on terminal goto project directory branch:ci-aws, update setting.xml file,  
repository url with maven-central-store connection setting.xml repository url(step:5),  
domain name and url:  `<id>devopstr-maven-central-store</id>`, `<url>https://devopstr-...........d.codeartifact.us-east-1.amazonaws.com/maven/maven-central-store/</url>`, 
- Update pom.xml with repo details: repositories url:`<url>https://devopstr-...........d.
codeartifact.us-east-1.amazonaws.com/maven/maven-central-store/</url>`,  
- commit and push to code commit repository.    

## Sonar Cloud
- Create sonar cloud account
- Generate sonar token:  
Goto sonar cloud, my account, security, generate token, name: vpro-sonar-cloud, generate token, grab token. At the top right click plus symbol, Create new organization, create an organization manually, name: devopstrvpro, choose free plan, create organization. at the top-left click sonarcloud, analyze new project, create a project manually, select your organization, display name: devopstrvpro-repo, give same name to projectkey(vprofile-repo), public, next, previous version, create project. Information section grab the project key, organization, url: https://sonarcloud.io.      
- Create SSM parameters with sonar details (check and follow from sonar_buildspec.yml), we use here parameter store but keep in mind best way is to use secret manager.  
Go to AWS System Manager, Parameter Store, Create,  
1. name: Organization, type string, value: get it from sonar cloud, create. 
2. name: HOST, type string, value: https://sonarcloud.io , create.  
3. name: Project, type string, value: project key get it from sonar cloud, create.  
4. name: LOGIN or sonartoken, type secure string, value: token we already grab from sonar cloud, create.  
5. name: codeartifact-token, type secure string, value: get it from this `echo $CODEARTIFACT_AUTH_TOKEN` create. 

## Build Project  
- Update pom.xml with repo details  
Open your code that you have already clone, with your IDE, change branch to ci-aws, under aws-files 
folder you see buildspec files which do the same job similiar to jenkinsfile.  
In pom.xml at the bottom change repository url: Go to code artifact repositories, click maven-central-store, view connection instruction, mac-linux, mvn, step 5 grab url, paste it.  
- Update setting.xml in source code  
profile > repository > url: paste same url, mirrors>code artifact,domain name maven-central-store> url paste same url.
- copy aws-files>sonar-buildspec.yml to project root folder where pom and setting.xml files stands. rename it just buildspec.yml.  
- Go to code artifact repositories, click maven-central-store, view connection instruction, mac-linux, mvn, step 3 Export .... copy the code mean export command, buildspec.yml file line 15 under commands cp .. , paste here  
save commit and push to AWS codeCommit repository.  
Go to Aws code commit and check pom.xml, setting.xml and buildspec.yml files in ci-aws branch.  
- Create Build project  
goto Build CodeBuild, create project, name: vpro-code-analysis, select source code provider and repo, branch:ci-aws, Environment image:managed image, os:ubuntu, runtime:standard, image:aws..../standard:5.0, Rolename: update role name to find easily (we will add more permission to access parameter store to this role), use a buildspec file, Logs: check cloudwatch logs, group name:vprofile-northvir-codebuild, Stream name: sonarCodeAnalysis,  create build project. İt will fail because the service role dont have access to parameter store by default. So we need to set it up manually.  
-  Update codebuild role to access SSMparameterstore: go to build project vpro-code-analysis project, edit,environment, copy the service role and give it to access parameters store permission. create policy, service:systems manager, list: check describe parameters, read: DescribeDocumentParameters, GetParameter, GetParameters, GetParameterHistory, GetParameterByPath, next policy name: vprofile-parameteresReadPermission, create. goto the role and attach the policy. attach another policy to the role, name: AWSCodeArtifactReadOnlyAccess. Start build. be sure to be success if it fail then fix it and start.  
Go to sonarcloud, your project, Main Branch check  

## Build Artifact  
- update build_buildspec.yml file:
- Go to code artifact repositories, click maven-central-store, view connection instruction, mac-linux,
mvn, step 3 Export .... copy the code mean export command, update build_buildspec.yml file line 11 under commands cp .. , paste here (export commands) 
save commit and push to AWS codeCommit repository.
- Go to existing project open in new tab keep it open and back existing tab, create build project, name: vprofile-Build-Artifact, select source code provider and repo, 
branch:ci-aws, Environment image:managed image, os:ubuntu, runtime:standard, image:aws..../standard:5.0,
Rolename: update role name to find easily (we will add more permission to access parameter store to this
role), use a buildspec file, Buildspec name: aws-files/build_buildspec.yml Logs: check cloudwatch logs, group name:goto another tab and get the log group name we use previously (edit, logs, grab the log group name ), Stream name: BuildArtifact,  create build project. It will fail because the service role dont have access to parameter store by default. So we need to set it up manually.  
- IAM, roles, find your role, click on that, add permission, attach policies, search artifact, select AWSCodeArtifactReadOnlyAcces, add permission. Start build. 

## Create CodePipeline and Notifications for SNS
- to store the artifact create s3 bucket,  
name:vprofile55-build-artifact, select right region, create bucket.  
- create folder to store artifact,  
name:pipeline-artifacts, create folder. (in the aws configuration it s called as key.)
- Create Notificaton go to sns,  
create topic, type:standard, name: vprofile-pipeline-notifications, create,  
create subscription, protocol: email, endpoint: give an email adress, create. confirm subscription through email.    
- Pipeline CodePipeline, Create pipeline, name: vprofile-CI-Pipeline, add a number to service role, source: AWS Code commit, fill repo name, branch name, detection:cloudwatch, Build Provider: AWS CodeBuild, project name: select vprofile-build-artifact, deploy stage skip it for now, create pipeline. Stop execution.  
- Edit pipeline, add stage after codecommit, name: CodeAnalysis, Add Action group for this stage, name:: SonarCodeAnalysis, provider:CodeBuild, select region, ınput artifact:SourceArtifact, project name:vpro-code-analysis, done. 
- add stage after Build, name: Deploy, Add Action group for this stage, name: DeployToS3, provider:Amazon S3, selct region, ınput artifact: BuildArtifact, bucket: select your bucket, S3 Object key: Folder name you created, check extract before deploy, done.  
- SAVE the pipeline. Go to Pipeline setting, Notifications, create notification rule, name: vpro-ci-notifications, detail type: full, select event in this case select all, choose target, submit.  
- back to pipeline, Release change, check sonar cloud, s3 bucket etc.


# Test Pipeline
- to test change readme.md, commit and push, check the result again.

# Continuous Delivery on AWS


## Create Elastic Beanstalk Environment  
- Create application: app name:vprofile-app, Platform: Tomcat, Platform branch: 
Tomcat 8.5 with Corretto 11 running on 64 bit Amazon Linuz 2, platform version:4.1.1, Sample application, Configure more options,  
capacity ==> ASG: auto scaling load balanced min:2 max:4, instance type keep just t2.micro, save  
security ==> select key pair (ci-vprofile-key), save  
Tags ==> Project vprofile, save, Create app  


## Create RDS
- Create Database  
Databases, Create Database, standard, engine MySQL, engine version:MySQL 5.6.34, template: free tier, Single DB Instance, name:vprofile-cicd-mysql, master username:admin, 
select auto generate a password, instance configuration: Burstable classes select db.t2.micro if not available db.t3.micro, public access No, create security group name:- 
vprofile-cicd-rds-mysql-sg, Additional setting: Initial database name:accounts create database. view credential details store them.  

##  SecGrp & DB Initialization
- Go to instances, grab beanstalk environment instances security group ids and go to rds security group, add inbound rule: type:MYSQL(3306), source:beanstalk environment 
instances security group ids.
- 
- ssh to beanstalk user: ec2-user, 

