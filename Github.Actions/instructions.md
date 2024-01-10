
## The Architecture  
So you will basically have a git repository. Integrate it with VS code. So we can write the code, push and pull the code to git repository which is on GitHub.  
GitHub action service is available in the GitHub account itself. Click on GitHub actions. create workflow and workflows will have jobs. The first job in the workflow will be to test the code. And in the job you have steps. The first step is to fetch the code which is again in the same GitHub account. In the git repository we will fetch the source code. That will be the first step in the job.  
The next step will use Maven test and Checkstyle to create unit test and Checkstyle test reports. And then Sonarqube is going to scan the source code again and check it with Sonar Cloud for the code quality. So far all this was happening on GitHub action. But now you have also sonar cloud integration with GitHub action.  
The next job in the workflow is to again fetch the source code from git. The second step will be to build the Docker image and push it to AWS ECR. So this is the second integration in your GitHub action workflow with AWS ECR Container Registry. So from GitHub action the image will be pushed to aws ECR. We have the image ready, which is also tested with the code.  
The next step is to deploy the container. Image is already on AWS ECR. Create ECS cluster on AWS. ECS cluster is going to fetch the image from AWS ECR. The deploy will tell ECS to fetch this version of the image. This tag of the image through task definition will send this information to that. Hey, you need to fetch this tag of this image which is container or ECS service will do, which is going to fetch the right image and run a container of it and it will be exposed through a load balancer. So it's going to fetch the image from AWS. ECR container also will need the access of the database. So we will have Amazon RDS created already for it. So it can access the database. And from the load balancer we are going to expose our container to the users.  

## Steps
1. GitHub setup  
- Fork the repository into your GitHub account.  
- SSH login to your GitHub repository.  
- Integrate that with the VS code. 
2. Test code  
- Creata a workflow (like to create pipeline in Jenkins) and jobs. first job in our workflow will be to test our code.
- Use Maven, Checkstyle and Sonar scanner to test and analyze source code.
- Upload all this result to Sonar Cloud and check for the quality gates.
3. Build & Upload Image
- Build the Docker from the source code 
- Upload it to AWS ECR 
4. Deploy to ECS
- Deploy our container or our Docker image to ECS.
- Set up the ECS cluster and task definition through GitHub action.
- Create one more job in the workflow where we'll have a task definition. We will have our own task definition for the ECS in our source code. We will mention the image tag, image name, and the tag to deploy. So when we push this information to ECS will have a new task definition that will have the new tag of our Docker image. It is going to fetch that from the ECR repository and run it.
- Create RDS for app container. RDS store SQL database. The application running in the container can access the database. And all this will be exposing it through a load balancer which will provide it by ECS service. So user can access the application through the load balancer.

## GitHub setup
- Setup SSH login to your GitHub repository
`cd ~/.ssh`, `ssh-keygen`, give github account name to identfy why you create this key, grab the public key and paste it to your github account ssh key section.  
Back to terminal run  `ssh -i ~/.ssh/id_ed25519 -T git@github.com` 
Fork the repo: `https://github.com/hkhcoder/hprofile.git`
Back to terminal and run `export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519 -T git@github.com"`  
back to terminal run `mkdir ~/codes/actions`
`cd ~/codes/actions`
`git clone git@github.com:yusuf-inci/hprofile.git`
`cd hprofile`
`unset GIT_SSH_COMMAND`
to inject key information in to this repo means whenever make any change from this repo it will use this ssh keys so run: `git config core.sshCommand "ssh -i ~/.ssh/id_ed25519 -F /dev/null"`  
`cat .git/config`  
`git config user.name <your name>`
`git config user.email <your email>`
`cat .git/config`  
integrate with VS Code

## AWS IAM, ECR & RDS
Region: ohio
- Fetch the source code from git repository. Build the docker image and upload it to AWS ECR.
- Manually setup the infrastructure on AWS  
- Create an IAM user which will have ECR registry policies. So we can upload our Docker images to a registry.  
- Create RDS database. Initialize the database with our tables with our schemas.  
- Store IAM keys and RDS details in GitHub secrets. So when we execute commands from our job, it will use those iam keys for authentication and RDS detail to inject in the source code before we build the image.  
- Iam user with policies `AmazonEC2ContainerRegistryFullAccess`, `AmazonECS_FullAccess`, generate access key,  
- Create ECR repo, 
- Create AWS RDS Database, standard, mysql, engine ver. 8.0.33, template free tier, db name: vproapp-actions, username: admin, password auto generate, dbt3.micro, create new sg, name vproappRDS-actions-sg, additional configurations initial database name: accounts, create database. as soon as create database click view credential details and store the password.
- create temporary ec2 instances to initialize (run some sql commands and deploy the schema) this rds, name: mysqlclient, ubuntu, free tier 22.04, t2micro, create key pair, create sg name: mysql-client-sg, 22 myip, launch instance.
- grab RDS endpoint and store it.  
- ssh to mysqlclient instance, and install mysql client `sudo -i`, `apt update && apt install mysql-client -y`,  
- update RDS sg to allow mysql-client-sg on port 3306, delete mysql/Aurora rule
- back to mysql client instance login to RDS `mysql-h <RDS endpoint> -u admin -p<password> accounts`, exit
- clone your repo, check the db_backup.sql file in src/main/resources then run `mysql-h <RDS endpoint> -u admin -p<password> accounts < src/main/resources/db_backup.sql`, login to RDS again and run `show tables` exit.
- terminate mysqlclient instance
- store all this information in the GitHub secret so we can access it in our pipeline, So go to your repository profile settings. Secrets and variables. Actions. new repository secret.
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- registry value. So come to your repository. Click on View Push Commands and get the account id. `AWS_ACCOUNT_ID`
- Next one is the registry URL. So go to your repository and click on View Push commands.
get the Docker Registry URL. `REGISTRY`
- RDS Details  
- `RDS_USER`
- `RDS_PASS`
- `RDS_ENDPOINT`

## Docker Build & Publish to ECR
1. Set up a job to build the Docker image and store it on AWS ECR. It's a multi-stage Dockerfile to build the app image which is based on Tomcat.
- first from the open JDK image install Maven and copy the source code.Then with the run instruction, CD into that folder and run Mvn install, which is going to generate the artifact. 
- The next image Tomcat image, remove the default application of Tomcat, and copy from the build image which is from this image. expose port 8080 and the command Katrina run. when we run the container it's going to execute this script. Run the Tomcat which will have our application hosted in it.  
2. open main workflow file. add a new job, BUILD_AND_PUBLISH, run on ubuntu latest runner  
- Steps, First check out the source code. 
- then Update application.properties file, search for the values in application properties and replace it with the value that we stored in secrets. use Linux command sed (write, search and replace), in order to run multiple command in different line, you just give a pipe symbol. so three things we need to change from application properties file username password and the endpoint.
-  Build & Upload image to ECR, use appleboy/docker-ecr-action@master actions from the marketplace. this is going to build the docker image and upload. Commit and push. go to our repository. actions. hprofile actions. if you make any syntax mistake in the Yaml file structure, it will detect it automatically.we can deploy this newly built image on the ECS cluster.

## ECS Setup  
- Setup the Elastic Container Service cluster to run our container.
- create a cluster.
- create task definition.
- create a service.  

1. Create Cluster: run it on AWS Fargate, 

2. Task definition is basically information of what task which container to run from, which image, what tag to use. 
- Create New Task definition, run it on AWS Fargate, reduce the memory size to two GB, In the dropdown here select Create New role. Container name. It's important to name it properly because we'll use this name later in the task definition file, Image uri, get the image Uri from ECR repository. Click on view push commands. And exclude the colon latest and copy it. So it's the Docker host Uri slash our repo name. Container port, our container is running the service on port 8080, Use log collection. this will take the container logs and store it on Amazon CloudWatch service which is very essential. also the role. The IAM role that this task definition uses should have access to CloudWatch logs service. give it after creation of this task definition file. update the IAM role of this task definition. create.
- give this role to access to CloudWatch logs service, add permission attach policies, search for CloudWatch logs full access Put a check mark. add permission.  
3. create a service: So go to your cluster. in the services click on create. run it on Fargate, Deployment configuration as a service. run a service, not just a single standalone task. family, select our task definition. this will provide the information and the revision. So revision one service name. give service a name, keep it one deployment options. Since we just have one, rolling update, Deployment failure detection initially. Make sure you uncheck this one later. Networking. Expand this networking. Keep this subnet as it is create new security groups. Give a name, So the rule. http Allowed from anywhere. Now this is for the load balancer that service will create. The load balancer will allow port 80 from anywhere, so any user in the internet can access it. add one more rule. Custom TCP. Port 8080. from anywhere. Now the security group will be used for the load balancer and for the container. select here application load balancer. Create new load balancer. give a name. Port 8080. Create new listener. Port 80. That is the load balancer port. Target group, give a name, health check give /login. create.
- check security groups Edit inbound rule. add 3306 is allowed from The Service Security Group. This will allow our service to connect to on port 3306.
- hit load balancer URL to browser, you should see the app.

## Deploy  
- the next job in our workflow will be to deploy our image. needs the capability to deploy the new image tag, or any image with any tag and the container information or the image information on the service is provided by the task definition. We will have this task definition in Json format in our source code and in the job, we will update
the task definition to the new tag and push this new task definition to ECS service. ECS service will detect that and make the changes fresh. Image tag it will pull from the ECR. So we have the Docker image on AWS ECR. create a new job, which is going to deploy the new task definition on ECS cluster, which we have already created. We have the load balancer. The task definition will have information of the new tag, which it will fetch from the ECR. And our container also has the access to the Amazon RDS. We already tested this from the URL, we are able to log in to our app container, our application which is running on the container.
- get the task definition file which is in Json format. go to task definitions. Click on your task definition. Revision. Json option. Click on that. copy it to the clipboard. Go to your VS code. and paste it inside to task definition file. 
- create a new job, Deploy, run it on ubuntu. step check out the source code. go to market place find Amazon ECS "Deploy Task Definition" Action for GitHub Actions use it as a template and update main.yml commit and push. Run workflow. check the deploy. Deploy Amazon ECS. Task definition. etc.
- update workflow run method both manually and push event. test it.
- conclusion: First we did the GitHub setup. We created a workflow a sample workflow. Then we included the testing job in that where we test the source code by using sonar scanner and sonar cloud. We created the second job which builds the Docker image and uploads to AWS, ECR. And before that we did a lot of AWS setup creating IAM user, creating ECR repository, creating RDS. Then we created the ECS cluster Task definition service. We tested our application. Then we mentioned the stage or job in the workflow to deploy the latest tag by using task definition on the ECS cluster. 

## Clean Up
RDS
- delete database
ECS
- delete service
- delete cluster
- delete the user that we created 
- remove the images.

