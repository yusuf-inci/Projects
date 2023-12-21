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
- JenkinsServer  
ssh, check: `systemctl status jenkins`, `java --version`, home directory of jenkins: `ls /var/lib/jenkins`, java: `ls /usr/lib/jvm`  
- connect jenkins via browser: `http://<public ip>:8080`, login jenkins and intall suggested plugin, intall following plugins: `maven integration`, `GitHub integration `, `Nexus Artifact Uploader`, `SonarQube Scanner`, `Slack Notification`, `Build Timestamp`, 
- NexusServer  
ssh, check: `systemctl status nexus`, connect via browser: `http://<public ip>:8081`, follow wizard disable anonymous access. Go to administrator/Repositories and create repositories: maven2 (hosted) name:vprofile-release, maven2 (proxy) name:vpro-maven-central remote storage url:https://repo1.maven.org/maven2/ , maven2 (hosted) name: vprofile-snapshot, version policy: Snapshot, maven2 (group) name:vpro-maven-group  add previously created repositories in it.  
- SonarServer  
connect via browser: `http://<public ip>`  

## Github Repository
## Build Job with Nexus Integration
## Github Webhook
## Sonarqube Integration
## Nexus Artifact Upload
## Slack Notification