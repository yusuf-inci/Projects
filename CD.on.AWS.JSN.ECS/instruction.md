# Continuous Delivery (java app) with Jenkins, Nexus, SonarQube, Slack, Docker on AWS ECS 

## Prerequisite
- Complete Continuous Integration on AWS with Jenkins, Nexus, SonarQube and Slack (CI.onAWS.JSNS) project. This project is its continuation.

## Tools
- Jenkins
- Nexus Sonatype Repository (Download maven dependency & upload artifact)
- SonarQube (sonarqube scanner for code analysis & sonarqube server to check the quality gates)  
- Maven (unit test, checkstyle & buil artifact)
- Git
- Slack
- Docker (containerize the artifact)
- ECR (store the containerized the artifact)
- ECS
- AWS CLI

## Steps
1. Update Github webhook with jenkins Ip
2. Copy Docker files from vprofile repo to your repo
3. Prepare two seperate Jenkinsfile for staging & prod in source code
4. AWS Steps
- IAM, ECR Repo setup
5. Jenkins Plugin Installation
- Amazon ECR
- Docker, Docker build & publish
- Pipeline: aws steps
6. Docker engine & awscli installation on Jenkins
7. Write Jenkinsfile for Build & publish image to ECR
8. AWS ECS setup (Cluster, Task Definition,Service)
9. Code for Deploy Docker image to ECS
10. Repeat the steps for prod ECS cluster
11. Promoting docker image for prod

## Update IP's
- Check security groups and verfiy ips  
- Grab Jenkins server public ip and goto github repo that you use in AWS ci project, update webhooks url with jenkins server ip. Check webhooks connection with Jenkins Server.  

## Prepare Source Code 
- Copy Docker files from vprofile repo to your repo: Go to `https://github.com/hkhcoder/vprofile-project` branch: `docker` and download zip file. Grab Docker-files folder and create new branch in your ci project repo, name it  `cicd-jenkins` and paste it.  
- Create two folder name them: `StagePipeline` and `ProdPipeline`. Copy Jenkinsfile in to both two folder. Remove Jenkinfile on root dir from git with `git rm Jenkinsfile`  
- check git config file `cat .git/config`, be sure you should merge to `ci-jenkins` branch. `git add .`, `git commit -m "preparing cicd branch"`, `git push origin cicd-jenkins`, check new branch and its files.  

## AWS IAM & ECR
- Create user name: cicdjenkins, attach `AmazonEC2ContainerRegistryFullAccess`, `AmazonECS_FullAccess` policies, grab access crendentials.
- Create private ECR registry repo name: vprofileappimg.  

## Jenkins Configurations
- Install Jenkins Plugin: `Docker Pipeline`, `Cloudbees Docker Build and Publish`, `Amazon ECR`, `Pipeline: AWS Steps`. 
- Store AWS credentials in Jenkins, Manage Credentials, Global Credentials, Add Credential, kind: AWS, ID:awscreds, put AWS credentials, 
- Install awscli and Docker engine (docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin) to Jenkins Server, add jenkins user to docker group `usermod -aG docker jenkins` check it `id jenkins`, restart jenkins service (sometimes restart isnt work and you get permission error then you need to reboot the jenkins server).
- test jenkins pipeline. goto repository `ci-jenkins` branch, make some changes, follow jenkins job. be sure job is triggered and running properly.

## Write Jenkinsfile for Build & publish image to ECR
- goto your repository, branch: cicd-jenkins, open your IDE
- Use multi stage Dockerfile: Docker-files/app/multistage/Dockerfile
- go to StagePipeline/Jenkinsfile,  
add registryCredential, appRegistry, vprofileRegistry variables.  
add Build App Image and Upload App Image stages, Commit and Push,  
- go to Jenkins and create new pipeline, name:vprofile-cicd-pipeline-docker, select `GitHub hook trigger for GITScm polling` , Configure pipeline definition from SCM, adjust the branch and path, Build now. Check logs, check ECR. 

## AWS ECS setup (Cluster, Task Definition, Service)  
1. Create Cluster, name:vprostaging, use fargate, use container insight, tags Name:vprostaging, create  
2. Create Task Definition, name:vproappstagetask, container name:vproapp, Image URI: grab from ecr, container port: 8080, task size: CPU: 1 vCPU, Memory: 2 GB, Create  
3. Deploy Service,  
- Launch type, select task definition family, service name: vproappstagesvc, Desired task 1,  
- Create new security group, name: vproappstagesg, same as description, inbound: HTTP anywhere,  
- Load Balancer: Application Load Balancer, name: vproappstageelb,  
- Create new target group, name: vproappstagetg, Healt check: /login, period: 30 seconds, Deploy.
- Update Target Group health check port 80 to 8080.    
- Update vproappstagesg security group, add inbound rule 8080 anywhere for IPV4 and IPV6
- Check service load balancer, click dns name and you should see app.   

## Code for Deploy Docker image to ECS (Pipeline for ECS)
- go to StagePipeline/Jenkinsfile,  
add cluster and service variables,  
add Deploy to ECS staging stage, Commit and Push,  
- go to Jenkins and check vprofile-cicd-pipeline-docker pipeline started, once it is finish check the logs. Check ECR. 

## Repeat the steps for prod ECS cluster
1. Create Cluster, name:vproprod, use fargate, use container insight, tags Name:vproprod, create  
2. Create Task Definition, name:vproprodtask, container name:vproapp, Image URI: grab from
ecr, container port: 8080, task size: CPU: 1 vCPU, Memory: 2 GB, Create  
3. Deploy Service,  
- Launch type, select task definition family (vproprodtask), service name: vproappprodsvc, Desired task 1,  
- Create new security group, name: vproappprodsvcsg, same as description, inbound: HTTP anywhere,  
- Load Balancer: Application Load Balancer, name: vproappprodsvcelb,  
- Create new target group, name: vproappprodsvctg, Healt check: /login, period: 30 seconds, Deploy.
- Update Target Group health check port 80 to 8080.    
- Update vproappprodsvcsg security group, add inbound rule 8080 anywhere for IPV4 and IPV6
- Check service load balancer, click dns name and you should see app.
4. Production Code for Deploy Docker image to ECS (Prod Pipeline for ECS)
- go to your repo and create new branch from `cicd-jenkins` branch for prod `git checkout -b prod` push (publish in IDE) go to ProdPipeline/Jenkinsfile, update jenkinsfile. Simply deploy to production environment  
update cluster and service variables,  
add Deploy to ECS Prod stage, Commit and Push,  
- go to Jenkins and create `vprofile-cicd-prod-pipeline`, copy from  `vprofile-cicd-pipeline-docker`, change branch to `*/prod`, Path: ProdPipeline/Jenkinsfile, Save. 
- go to ECS, check clusters, service and wait for some time, make sure it is stable then got jenkins, test your pipeline, Build now.  
- once it is finish check the logs. Check the ECS. 

## In Real Time Production Scenario
- After staging environment get ready to pass the prod (once it approved) Staging code will be merged with prod code. (Both codes need to be similiar). In this case cicd-jenkins is staging code so merge cicd-jenkins to prod. `git checkout prod`, `git merge cicd-jenkins`, `git push origin prod`, As soon as the changes goes to the production branch, `vprofile-cicd-prod-pipeline` should get triggered. After some tests (smoke, sanity etc.), user request directed to production environment. Ofcourse it can be different organization to organization. Generally merge --> pull reguest --> approved --> pipeline gets triggered.  

## Clean up
- Delete ECS cluster. Before delete cluster, you should delete the service.(it also delete task) 
- Terminate Jenkins, Nexus, Sonar Server. In this case just stop them.