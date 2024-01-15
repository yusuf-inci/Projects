# Containerization of Java project with Docker
## Instructions and Commands
- prerequisite:  
- Install Vagrant
`curl -O https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb`  
`sudo apt install ./vagrant_2.2.9_x86_64.deb`
- Initialize vagrant with ubuntu box and configure vagrantfile accordingly or use vagrantfile  
`vagrant init "ubuntu/jammy64"`  

## Docker hub and Docker file References
- create docker hub account and create three repositories  
`vprofileapp`, `vprofiledb`, `vprofileweb`  
- grab application source code, docker and docker compose template (empty files) from `https://github.com/devopshydclub/vprofile-project.git`  
- goto project directory that vagrant file stands. Open terminal and create vm `vagrant up`. to connect vm use `vagrant ssh`  

## Create Docker Files  
Before starting the code you should understand project and used tools. you should know what you will do, which image, tag etc. you use. all steps to setup stack services. Go to project directory find the template and write the codes.  
- App Docker file:  
Find right base image from docker hub. Write Dockerfile to customize image. In this case you can use either maven and tomcat image separately or you can write multi stage docker file. In this case we use multi stage docker file. Find the right image, first part of docker file install maven, clone source code, build artifact. Second part delete default app in tomcat and copy artifact that you build and run tomcat.  
- Db Docker file:  
Find right image, use environment variable and copy or add db_backup.sql to /docker-entrypoint-initdb.d/db_backup.sql.  
- web Docker file:  
Find right image, delete default configuration and use custom configuration. it is in nginvproapp.conf file. so copy it to /etc/nginx/conf.d/vproapp.conf  
- You can build one by one or all in docker compose  

## Create Docker Compose  
Creating a template is a right way before you start coding. Write docker compose file to run multi container.
- goto project directory that vagrant file stands. Open terminal
and connect to vm use `vagrant ssh`, `sudo -i`, `cd /vagrant`.
- Build images and test it. `docker compose build`, `docker images`, `docker compose up -d`, `docker ps`, grab the ip address `ip addr show`, back your host machine and past it to browser. Back to vm open terminal and login your docker hub account `docker login`, `docker images`, push the images and host them on docker hub.: `docker push <devopstr55/vprofileapp>`, `docker push <devopstr55/vprofiledb>`, `docker push <devopstr55/vprofileweb>` 

## Clean up  
- docker stop <container id>  
- to remove stopped containers and related part
`docker systemprune -a`