# Instructions and Commands
- prerequisite:
- Region: us-east-1 (North Virginia) 
- Go to Certificate Manager 
Request Certificate (Public Certificate), name it *.example.com, DNS Validation, give tag name:domain name.  
Add CNAME name without domain part including . and value without . at the end to registrar(ex:go daddy), verify certificate on AWS CM issued or not  
1. Key Pairs
- Name:vprofile-prod-key 
2. Security Groups
- vprofile-ELB-SG 
inbound: HTTP and HTTPS source-anywhere
- vprofile-app-sg 
inbound:
8080 from vprofile-ELB-SG  
22 from My IP (TroubleShouting purpose)  
8080 from My IP (TroubleShouting purpose)  
- vprofile-backend-SG 
inbound: 
Mysql(3306) from vprofile-app-sg  
11211(memcache) from vprofile-app-sg  
5672 (rabbitmq) from vprofile-app-sg  
All Traffic from vprofile-backend-SG(itself)  
22 from My IP (TroubleShouting purpose)  
3. Instances with user data
- On host: clone repo: https://github.com/hkhcoder/vprofile-project.git 
Change branch to aws-LiftAndShift. Use script under userdate for each app.
- On AWS Console create ec2
- name: vprofile-db01, add tag Project:vprofile, ami: on market place use CentOS Stream 8, instance type: t2micro, key pair: vprofile-prod-key, security groups: vprofile-backend-SG, userdata: use mysql.sh, Launch İnstance 
- name: vprofile-mc01, add tag Project:vprofile, ami: on market place use CentOS Stream 8, 
instance type: t2micro, key pair: vprofile-prod-key, security groups: vprofile-backend-SG,
userdata: use memcache.sh, Launch Instance 
- name: vprofile-rmq01, add tag Project:vprofile, ami: on market place use CentOS Stream 8,
instance type: t2micro, key pair: vprofile-prod-key, security groups: vprofile-backend-SG,
userdata: use rabbitmq.sh, Launch Instance 
- name: vprofile-app01, add tag Project:vprofile, ami: Ubuntu Server 22.04 LTS,
instance type: t2micro, key pair: vprofile-prod-key, security groups: vprofile-app-sg,
userdata: use tomcat_ubuntu.sh, Launch Instance
- verify all instances with ssh. Use `centos` user for CentOS instances.
- vprofile-db01  
`sudo -i`  
`systemctl status mariadb`  
`curl -I https://www.google.com`  
`curl http://169.254.169.254/latest/user-data`  
`mysql -u admin -padmin123 accounts`  
`show tables;`  
`quit`  
- vprofile-mc01   
`sudo -i`  
`systemctl status memcached`  
`ps -ef | grep memcache`  
`ss -tunlp`  
`ss -tunlp | grep 11211`  
- vprofile-rmq01  
`sudo -i`  
`systemctl status rabbitmq-server`  
- vprofile-app01  
use `ubuntu` user for shh  
`sudo -i`  
`systemctl status tomcat9`  
`ls /var/lib/tomcat9/webapps`  
4. Update Ip to name mapping in Route 53
-  Route 53 ==> create hosted zone ==> vprofile.in ==> Private hosted zone ==> select region and vpc ==> create hosted zone
- Create Record ==> Simple Routing ==> Define Simple Record ==> db01 ==> private ip ==> Define Simple Record
- create record for mc01 and rmq01 
5. Build application
- goto project directory update application.properties file(src/main/resources/). db01 to db01.vprofile.in, mc01 to mc01.vprofile.in, rmq01 to rmq01.vprofile.in 
- open terminal on your host machine and goto directory where pom.xml stands. Run `mvn -version` be sure maven 3.9.2, java 11 and aws cli are installed. Run `mvn install`. Go to target folder and be sure artifact is ready.    
6. Upload to S3 bucket
Create a user named s3admin, attach AmazonS3FullAccess policy, create user. Create access key for this user. Configure your aws cli with this user. Create s3bucket `aws s3 mb s3://vpro-art<random number>`  
Copy artifact to s3: `aws s3 cp target/vprofile-v2.war s3://<bucket name>`
7. Download Artifact to Tomcat instance
- In order to authenticate this instance with s3 use iam role. Go to console iam service and create role named vprofile-s3 with AmazonS3FullAccess policy. Attach this role to app01 instances. Actions ==> Security ==> Modify IAM Role ==> select  vprofile-s3 role  
- ssh to vprofile-app01, install aws cli and copy artifact to here `aws s3 cp s3://<bucket name>/vprofile-v2.war /tmp/`
- stop tomcat9 service, remove default app: `rm -rf /var/lib/tomcat9/ROOT`,  
copy artificat: `cp /tmp/vprofile-v2.war /var/lib/tomcat9/webapps/ROOT.war`,  
start tomcat9 service. check the artifact extracted or not: `ls /var/lib/tomcat9/webapps`,  verify application properties filethat you edited: `cat /var/lib/tomcat0/webapps/ROOT/WEB-INF/classes/application.properties`  
8. Setup ELB with HTTPS
- Before to create application load balancer, create target group, Target group name: vprofile-app-TG, port 8080, healt check path:/login, Override:8080, healthty threshold:3, instance:tomcat app01, include as pending below, Create target group.
- Create Load Balancer ==> ALB ==> name:vprofile-prod-elb ==> internet facing ==> select all zones, sg:ELB-sg ==> Listener :HTTP 80, HTTPS 443, Default Action: vprofile-app-TG ==> select certificate ==> create Load Balancer.
9. Map ELB Endpoint to website name in Godaddy DNS
- Copy ELB Endpoint (DNS name) and CNAME record on registrar(go daddy), Host:vprofileapp, Points to:paste ELB Endpoint.
10. Verify
- open browser https://vprofileapp.domain name
11. Auto Scaling
- Create Ami: ec2 console select app01 instance ==> actions ==> image ==> create image ==> name:vprofile-app-image ==> create image.   
- Launch Configuration for Auto Scaling group: Create Launch Configuration ==> name:vprofile-app-LC ==> select ami ==> instance type:t2micro ==> iam role: vprofile-artifact-role ==> enable EC2 detailed monitoring within CloudWatch ==> sg: vprofile-app-sg ==> add key pair ==> create Launch Configuration.
- Create Auto Scaling Group: name:vprofile-app-ASG ==> select launch configuration ==> select vpc and all the subnet ==> enable load balancing select target group ==> check health check ELB ==> capasity : 1 - 1 - 4 ==> Target tracking Scaling Policy ==> add notification ==> tag:name:vprofile-app ==> create auto scaling group
- terminate vprofile-app01 instances. Check target group 
12. Verify
- open browser https://vprofileapp.domain name