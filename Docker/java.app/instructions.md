# Instructions and Commands
- prerequisite:  
- Install Vagrant
`curl -O https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb`  
`sudo apt install ./vagrant_2.2.9_x86_64.deb`
- Initialize vagrant with ubuntu box and configure vagrantfile accordingly or use vagrantfile  
`vagrant init "ubuntu/jammy64"`  
- to connect vm use `vagrant ssh`
## Docker hub and Docker file References
- create docker hub account and create three repositories  
`vprofileapp`, `vprofiledb`, `vprofileweb`  
- grab application source code, docker and docker compose template (empty files) from `https://github.com/devopshydclub/vprofile-project.git`
