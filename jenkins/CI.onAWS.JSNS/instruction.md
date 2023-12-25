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
- Clone vprofile repo with branch name  
`git clone -b ci-jenkins https://github.com/devopshydclub/vprofile-project.git`
  
`mv vprofile-project <repositoryname>`  
`cd <repositoryname>`  
- Replace the remote url  
`git remote set-url origin git@github.com:imnowdevops/<repositoryname>.git` 
 git@github.com:yusuf-inci/vprofile-project.git
`cat .git/config`  
`git branch -c main`
`git checkout main`
`git push --all origin`
`code .`
## Build Job with Nexus Integration
- Add java and maven tools to jenkins: Manage Jenkins, Global Tool Configurations, Add Jdk: name:OracleJDK11 and OracleJDK8, uncheck install automatically, ssh to jenkins server and install jdk 8 manually: `sudo apt update` , `sudo apt install openjdk-8-jdk -y`. Now we have two jdk 11 and 8, to see: `ls /usr/lib/jvm`, grab full path for jdk 11:`/usr/lib/jvm/java-1.11.0-openjdk-amd64` jdk 8: `/usr/lib/jvm/java-1.8.0-openjdk-amd64` and back to UI and paste it to JAVA_HOME for both of them. 
Maven Installation: name: MAVEN3 , select version on 3.9.5,  save.  
- Add Nexus Credential to Jenkins: Manage Jenkins, Credentials, System, Global Credentials, Add Credentials, kind:Username and Password: , ıd:nexuslogin, ok.
- Add and configure jenkinsfile
- Dashboard, New item, name: vprofile-ci-pipeline, Pipeline, OK, under pipeline Pipeline script from SCM: SCM:git, give ssh url for your repo, add credential, ssh username with private key, id:githublogin, username:git, private key enter directly: paste private key, add, select credentials. ssh to jenkins server, switch to root user then jenkins user `sudo -i`, `su - jenkins`, `git ls-remote -h <ssh url of your repo> HEAD` check known host, `cat .ssh/known_hosts` back to jenkins select credential again until the error disappear, select right branch, save.
- build now  

## Github Webhook
- grab public ip of your jenkins server, go to github repository, settings, webhooks, add webhook, paste url `http://<public ip>:8080/github-webhook/`,       
content type: application/json, choose events you would like the trigger this webhook, add webhook, click the url that web hook use, recent deliveries and check the ping status mean green check mark.
- goto jenkins UI and click your job, Configure, build triggers, check GitHub hook trigger for GITScm polling (in this case select push ), save.  
- add more stage to jenkinsfile and commit and push it and check the webhook. Your pipline job should start.
## Sonarqube Integration  
- In order to see test and checkstyle analysis human readable reports that we generate in our pipeline (surefire-reports and checkstyle-result.xml) we should integrate sonarqube server to jenkins.
1. sonar scanner tool: Add tools to jenkins: Manage Jenkins, Global Tool Configurations, Add sonarqube scanner, name: sonarscanner, version:4.7.0.2747, save.   
2. sonarqube server information that jenkins use to upload reports: configure system, SonarQube servers, check environmental variables, Add sonarqube, name:sonarserver, http://<private ip> save. goto sonar server generate token: Administrator, security, generate token and grab it. back to jenkins, configure system,  SonarQube servers, SonarQube installation, server authentication token, add , kind secret text, paste token, id:sonartoken, add, select token, save.  
- update jenkins file add the code that upload all reports to sonarqube server.  
- Create own quality gate: On sonarqube server, Quality gates, create, name:vprofileQG, save, add condition, on overall code, bugs, value:25, add condition. Go to projects, project setting quality gate, select  vprofileQG. Project setting, web hooks, create, name:jenkinswebhook, url:http://<private ip jenkins,>:8080/sonarqube-webhook, create. write quality gate stage in jenkins file, commit and push. jenkins job should failure due to quality gate, error message:ERROR: Pipeline aborted due to quality gate failure: ERROR
check it and back to sonar and update condition value to 100, run pipeline again and it will be success.       

## Nexus Artifact Upload  
- before upload artifact to nexus we update its name (versioning). For this we use jenkins timestamp plugin. we have already install `Build Timestamp` plugin. Configure it. Manage jenkins, system, Build time stamp, pattern:`yy-MM-dd_HHmm`, save.
- to upload artifact to nexus, we use jenkins `Nexus Artifact Uploader` plugin. we have already install it. Configure it. Manage jenkins, system, Build Timestamp, pattern:`yyyy-MM-dd HH:mm:ss`. update jenkinsfile add a stage `UploadArtifact`. commit push and test.  

## Slack Notification  
- create slack account,  
- create workspace, name:vprofilecicd, team working on: devopscicd, give email address.  
- add channel (like a group), create a new channel, name: jenkinscicd, create. google `add apps to slack`, click the link, search for jenkins click `Jenkins CI`,  click add to slack, choose channel:jenkinscicd, Add Jenkins CI integration, grap the token, save setting. 
- integrate with jenkins: manage jenkins, system, Slack, workspace:`vprofilecicd`, Credential add, kind: secret text, secret: paste token, id: slacktoken, add. select slack token, Default channel id: jenkinscicd, test connection, save.  
- update jenkinsfile to send notification pass or fail.   