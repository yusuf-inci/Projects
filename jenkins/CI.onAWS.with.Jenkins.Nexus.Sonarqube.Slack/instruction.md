## Login AWS  
Region: us-east-1 (North Virginia)
## Key Pair
Name:vprofile-ci-key
## Security Group
- name: jenkins-SG  
inbound:  
ssh source myip  
8080 source-anywhere // for github webhook 
After creating sonar-SG
8080 source - sonar-SG
- name: nexus-SG  
inbound:  
ssh source myip  
8081 source-anywhere  
8081 source-jenkins-SG  
- name: sonar-SG  
inbound:  
ssh source - myip  
80 source - myip
80 source -jenkins-SG  



## EC2 Instances
## Post Installation
## Github Repository
## Build Job with Nexus Integration
## Github Webhook
## Sonarqube Integration
## Nexus Artifact Upload
## Slack Notification