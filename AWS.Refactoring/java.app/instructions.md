# Instructions and Commands
- prerequisite:
- Region: us-east-1 (North Virginia) 
- Go to Certificate Manager 
Request Certificate (Public Certificate), name it *.example.com, DNS Validation, give tag name:domain name.  
Add CNAME name without domain part including . and value without . at the end to registrar(ex:go daddy), verify certificate on AWS CM issued or not  
## Key Pair for Beanstalk
- Name:vprofile-bean-key 
## Security Groups
- vprofile-backend-SG 
inbound:
22 from My IP (Dummy rule. To Create internal access rule)
All Traffic from vprofile-backend-SG(itself)

## Create Backend Services
1. RDS  
- Create Subnet Group  
name:vprofile-rds-sub-grp, select vpc, select all the availability zones and subnets, create.  
- Create Parameter Groups  
Select mysql8.0, name: vprofile-rds-para-grp, create.  
- Create Database  
Databases, Create Database, engine MySQL, engine version:MySQL 8.0.32, template: free tier, Single DB Instance, name:vprofile-rds-mysql, master username:admin, select auto generate a password, isntance configuration: Burstable classes enable include previous ....button select db.t2.micro if not available db.t3.micro, storage type:gp2, 20 gb, DB subnet group: vprofile-rds-sub-grp, sg: vprofile-backend-SG, Initial database name:accounts, paramater group: vprofile-rds-para-grp, log exports: select all, create database.  
View Credentials and grab the password, keep it   

2. Amazon Elastic Cache  
- Create Subnet Group  
name:vprofile-memcached-sub-grp, select vpc, select all the availability zones and subnets, 
create.  
- Create Parameter Groups  
name: vprofile-memcached-para-group, Family:memcached1.6 create.  
- Create Cluster  
Dashboard, Create Cluster, Create Memcached Cluster, name: vprofile-elascticcache-svc, engine: 1.6.17   , port: 11211, select parameter group, node type: cache.t2.micro, numer of nodes: 1, select subnet group, select security group: vprofile-backend-SG, create.    

3. Amazon Active MQ  
Engine type: RabbitMQ, Single instance, name:vprofile-rmq, instance type:mq.t2.micro or mq.t3.micro, rabbit, Blue7890bunny, engine version: keep default or 3.10.20, Private Access, select sg, create.  
- take a note
note to RDS endpoint, username and password  
note to Elastic Cache endpoint(remove port number at the end including colon: .), username and password  
note to Active MQ endpoint(remove port number at the end including colon: .)(remove amqps:// part at the begining), username and password  

## Launch Ec2 for DB Initializing
1. Launch Ec2 for DB Initializing  
- name:mysql-client, ubuntu Server 22.04 LTS, t2.micro, vpro-bean-key, create sg: 
mysql-client-sg inbound ssh my ip 
- update backend SG, inbound mysql-client-sg TCP 3306 
- ssh to mysql-client instance install mysql client:  
`sudo apt update && sudo apt install mysql-client -y`  
`mysql -h rdsendpoint -u admin -ppassword accounts`  
`show tables;` and `exit`  
back to bash and clone source code  
repo: https://github.com/hkhcoder/vprofile-project.git  
`cd vprofile-project``  
execute sql queries: `mysql -h rdsendpoint -u admin -ppassword accounts < src/main/resources/db_backup.sql`  
login rds again: `mysql -h rdsendpoint -u admin -ppassword accounts`  
`show tables;` and `exit`  
- terminate mysql-client 


## Create Elastic Beanstalk Environment  
- Create Role: AWS Service, EC2, policy name:`AWSElasticBeanstalkWebTier` `AdministratorAccess-AWSElasticBeanstalk` `AWSElasticBeanstalkRoleSNS` `AWSElasticBeanstalkCustomPlatformforEC2Role`, Role name:vprofile-bean-role, create role.  
Note: if you see `aws-elasticbeanstalk-service-role` delete it.
- Create application: Environment tier: Web Server environment, app name:vprofile-app, environment name: Vprofile-app-prod, Domain: vprofileapp55 (check availability), Platform: Tomcat, Platform branch: Tomcat 8.5 with Corretto 11 running on 64 bit Amazon Linuz 2, platform version:4.3.7, Presets:Custom Configuration, Service Access Service role:Create and use new service role: aws-elasticbeanstalk-service-role, key pair:vprofile-prod-key, EC2 instance profile:vprofile-bean-role, Public ip adress check Activated, select all subnet, Tags: name vproapp Project vprofile, if you get an error uncheck us-east-1e, auto scaling load balanced min:2 max:2, instance type keep just t3.micro, deployment policy: Rolling Percentage 50, Read documentation for detailed policy, create.  
  
## Post Configuration  
- Enable ACL on S3 Bucket  
Go to S3 bucket starting with elasticbeanstalk.... be sure the region is same, permissions, Object Ownership, Edit and check ACLs enabled radion button.     
- Update Healthcheck on Beanstalk  
On Beanstalk, goto your Environment, on left side click Configuration, Instance Trafffic and scaling click edit, Process, click default, action edit, Health check, Path /login, Sessions click Session stickiness Enabled, save.  
- Add 443 http Listener to ELB  
On Beanstalk, goto your Environment, on left side click Configuration, Listener, Add Listener, 443 HTTPS select certificate, add. ==> Apply  
- Update Beanstalk SG  
Grab Beanstalk instances security group ID, On Backend Securitiy Group (vprofile-backend-SG) inbound: add rule, All Traffic source --> Beanstalk instances security group ID  
  
## Build application
- On host: clone repo: https://github.com/hkhcoder/vprofile-project.git, keep main branch or change branch to aws-refactor.  
- goto project directory update application.properties file on src/main/resources/. db01 to 
RDS endpoint, update username and password if needed, do same for mc01 and rmq01. For rmq port = 5671.  
- open terminal on your host machine and goto directory where pom.xml stands. Run `mvn-version` be sure maven 3.9.2, java 11 and aws cli are installed. Run `mvn install`. Go to target folder and be sure artifact is ready.  
- Deploy Application: Elastic Beanstalk, Environments, find your environment and select it, upload and deploy, choose artifact, change version to v2.5, Deploy.
- Check app via browser.
- to enable HTTPS add beanstalk endpoint to godaddy as cname name vprofile.  
- Verify app via browser. `https://vprofile.devopstr.info`  
  
## Create CDN with SSL Certificate  
- Create Cloudfront distribution, Origin: vprofile.devopstr.info, protocol: Match viewer, allowed HTTP methods select all get, head, options, put, ... , select SSL certificate, security policy: TLSv1, create distribution  

## Verify  
- Open different browser ex.firefox cognito mod, `https://vprofile.devopstr.info`, press F12 and refresh browser again, you should see cloudfront under Headers in via line. 

## Clean up
- CloudFront: Disable, after disabled delete it.  
- RDS: Action delete uncheck create final snapshot, i acknowledge... , delete  
- ElasticCache: Action delete  
- AmazonMQ: delete  
- Beanstalk: Action Terminate environment 