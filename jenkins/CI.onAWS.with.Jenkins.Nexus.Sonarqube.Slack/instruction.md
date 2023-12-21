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
for user data: `https://github.com/hkhcoder/vprofile-project` branch: `ci-jenkins`  
- Create ec2 for jenkins:  
name: JenkinsServer, image: ubuntu 22.04 LTS (free tier), instance type: t2small if your instances hangs or any problem then change it to t2.medium, key-pair: vprofile-ci-key, Security Group: jenkins-SG, user data: jenkins-setup.sh, Launch İnstance  
- Create ec2 for nexus:  
name: NexusServer, image: in market use CentOS Stream 9 (login user:ec2-user not CentOS), instance type: t2.medium, key-pair: vprofile-ci-key, Security Group: nexus-SG, user data: nexus-setup.sh, Launch İnstance  
- Create ec2 for sonar:  
name: SonarServer, image: ubuntu 22.04 LTS (free tier), instance type: t2.medium, key-pair: vprofile-ci-key, Security Group: sonar-SG, user data: sonar-setup.sh, Launch İnstance  
## Post Installation
## Github Repository
## Build Job with Nexus Integration
## Github Webhook
## Sonarqube Integration
## Nexus Artifact Upload
## Slack Notification