
## Jenkins İnstallation
- Create an EC2 instance on AWS  
Launch instances with named JenkinsServer, ami ubuntu 20.04 LTS, type:t2.micro, key pair: jenkins-key, security group: jenkins-SG inbound ssh and 8080 from my ip, userdata: jenkins.install.sh  
- connect to jenkins server via ssh and check `sudo systemctl status jenkins` be sure active and running. Jenkins Home Directory: `/var/lib/jenkins`. Password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`, copy the password 
- connect to jenkins server with public ip port 8080 via your browser. Paste the password, next select plugins to install, uncheck ant and check NodeJS, next create first user.  get ip:`http://54.234.137.125:8080/`  

## Tools in Jenkins
- check jdk 8 and maven installed: Manage Jenkins, Global Tool Configurations, Add Jdk: name:OracleJDK8, uncheck install automatically, back to jenkins server with ssh and install jdk 8 manually: `sudo apt update` , `sudo apt install openjdk-8-jdk -y`. Now we have two jdk 11 and 8. to see: `ls /usr/lib/jvm`, grab full path jdk 8: `/usr/lib/jvm/java-1.8.0-openjdk-amd64` and back to UI and paste it to JAVA_HOME. Maven Installation: name: MAVEN3 , select version on 3,  save.  

## Sample Pipelne
- Add required plugins: Manage Jenkins, Manage Plugins, `Pipeline Utility Steps`, `Pipeline Maven Integration`, install without restart.  
- Dashboard, New item, name: sample-paac, Pipeline, OK, grab the code from code editor and paste it, save. Build Now.  


## With Docker Agent
- install `Docker` and `Docker Pipeline` plugin  
- fix the permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: issues : `sudo usermod -a -G docker jenkins`, `grep docker /etc/group`, logout or rebbot.  
- 