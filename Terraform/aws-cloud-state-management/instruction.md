# AWS Refactoring with Terraform - Java Application

## Prerequisite
- Create a Repository `git@github.com:yusuf-inci/terraform-aws-java.git`
- Install and setup terraform
- Install and configure aws cli
- Create s3 bucket and a folder name it terraform in newly created bucket for terraform state
- 

## Terraform files
- create backend configuration file. run `terraform init`, `terraform validate`, `terraform fmt`, `terraform plan`, `terraform apply`.
- create variable, provider and vpc (use terraform-aws-modules/vpc/aws module), configuration files and test it.
- create security group configuration file and test it.
- create backend services (RDS, Elasticcache memcached, Active MQ) configuration file and test it.
- create elastic beanstalk application and elastic beanstalk environment configuration file and test it, apply.
- cretae db_deploy.tmpl and bastion-host configuration file and test it, apply.

## Artifact Deployment
- clone vprofile project `https://github.com/devopshydclub/vprofile-project.git`, go to project directory `cd vprofile-project`, checkout vp-rem branch `git checkout vp-rem`, update application.properties file located in `src/main/resources/...`, (rds endpoint, port, username and password, memcache endpoint, port, username and password, rmq endpoint [AMQP] and port, username and password. 
- go to project directory  where pom.xml file stands, generate artifact `mvn install`, check artifact it shoul be in target directory, 
- upload and deploy artifact to beanstalk. go to elactic beanstalk, vprofile-bean-prod, upload and deploy, choose file: select vprofile-v2.war, version label: vprofile-v5.4, deploy

## Validate
- click the application link on beanstalk and test application

