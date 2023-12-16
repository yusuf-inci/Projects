# Instructions and Commands
- prerequisite:  
- Install Vagrant
`curl -O https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb`  
`sudo apt install ./vagrant_2.2.9_x86_64.deb`
- Initialize vagrant with ubuntu box and configure vagrantfile accordingly `vagrant init "ubuntu/jammy64"` and run `vagrant up` or use vagrantfile directly run `vagrant up`

## Create Docker Compose  
- goto project directory that vagrant file stands. Open terminal
and connect to vm use `vagrant ssh`, `sudo -i`, `cd /vagrant`.
- Build images and test it. `docker compose build`, `docker images`, `docker compose up -d`, `docker ps`, grab the ip address `ip addr show`, back to host machine and past it to browser. Check the app.  

## Clean up  
- docker stop <container id>  
- to remove stopped containers and related part
`docker systemprune -a`