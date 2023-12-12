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
note to Elastic Cache endpoint(remove port number at the end including colon: .), username and 
password
note to Active MQ endpoint(remove port number at the end including colon: .)(remove amqps:// part at the begining), username and password

## Launch Ec2 for DB Initializing
1. Launch Ec2 for DB Initializing  
- name:mysql-client, ubuntu Server 22.04 LTS, t2.micro, vpro-bean-key, create sg: 
mysql-client-sg inbound ssh my ip 
- update backend SG, inbound mysql-client-sg TCP 3306 
- ssh to mysql-client instance install mysql client:  
`sudo apt update && sudao apt update mysql-client -y`  
`mysql -h rdsendpoint -u admin -ppassword accounts`  
`show tables;` and `exit`  
back to bash and clone source code  
repo: https://github.com/hkhcoder/vprofile-project.git  
execute sql queries: `mysql -h rdsendpoint -u admin -ppassword accounts < src/main/resources/
db_backup.sql`  
login rds again: `mysql -h rdsendpoint -u admin -ppassword accounts`  
`show tables;` and `exit`  
- terminate mysql-client 


## Create Elastic Beanstalk Environment  
- Create Role: AWS Service, EC2, policy name:`AWSElasticBeanstalkWebTier` `AdministratorAccess-AWSElasticBeanstalk` `AWSElasticBeanstalkRoleSNS` `AWSElasticBeanstalkCustomPlatformforEC2Role`, Role name:vprofile-bean-role, create role.  
Note: if you see aws-elasticbeanstalk-service-role delete it.
- Create application: Environment tier: Web Server environment, app name:vprofile-app, environment name: Vprofile-app-prod, Domain: vprofileapp55 (check availability), Platform: Tomcat, Platform branch: Tomcat 8.5 with Corretto 11 running on 64 bit Amazon Linuz 2, platform version:4.3.7, Presets:Custom Configuration, Service Access Service role:Create and use new service role: aws-elasticbeanstalk-service-role, key pair:vprofile-prod-key, EC2 instance profile:vprofile-bean-role, Public ip adress check Activated, select all subnet, Tags: name vproapp Project vprofile, if you get an error uncheck us-east-1e, auto scaling load balanced min:2 max:2, instance type keep just t3.micro, deployment policy: Rolling Percentage 50, Read documentation for detailed policy, create.     


## Update Backend SG
1. Allow mysql-client-sg TCP 3306
1. Allow Traffic from Bean SG
2. Allow Internal Traffic




## 

2. Initialize RDS DB
3. Update Healthcheck on Beanstalk
4. Add 443 http Listener to ELB

## Buil Artifact with Backend info
## Deploy
1. Deploy Artifact to Beanstalk
2. Create CDN with SSL Certificate
3. Update GoDaddy DNS Entry
## Verify

