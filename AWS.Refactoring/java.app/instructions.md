# Instructions and Commands
- prerequisite:
- Region: us-east-1 (North Virginia) 
- Go to Certificate Manager 
Request Certificate (Public Certificate), name it *.example.com, DNS Validation, give tag name:domain name.  
Add CNAME name without domain part including . and value without . at the end to registrar(ex:go daddy), verify certificate on AWS CM issued or not  
## Key Pair for Beanstalk
- Name:vprofile-prod-key 
## Security Groups
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
## Create Backend Services
1. RDS
2. Amazon Elastic Cache
3. Amazon Active MQ

## Create Elastic Beanstalk Environment

## Update Backend SG
1. Allow Traffic from Bean SG
2. Allow Internal Traffic


## Launch Ec2 for DB Initializing
1. Launch Ec2 for DB Initializing
2. Initialize RDS DB
3. Update Healthcheck on Beanstalk
4. Add 443 http Listener to ELB

## Buil Artifact with Backend info
## Deploy
1. Deploy Artifact to Beanstalk
2. Create CDN with SSL Certificate
3. Update GoDaddy DNS Entry
## Verify

