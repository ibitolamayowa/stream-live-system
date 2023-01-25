#!/bin/bash

cd /home/ubuntu
touch file
# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# Install Node.js
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo apt install -y docker-compose

# Clone repository and run commands
git clone https://github.com/ibitolamayowa/stream-live-system.git
sudo chown -R ubuntu:docker stream-live-system/


cd stream-live-system
cd rabbitmq
sudo docker-compose up -d
cd ..

cd micro-live-manager
sudo docker-compose up -d
cd ..

cd micro-live-streaming
sudo docker-compose up -d
cd ..

# Setup a GitHub webhook
git init
touch .git/hooks/post-receive
chmod +x .git/hooks/post-receive

echo "#!/bin/bash
while read oldrev newrev ref
do
    branch=\$(git rev-parse --symbolic --abbrev-ref \$ref)
    if [ \"\$branch\" == \"master\" ]; then
        cd rabbitmq
        git pull origin master
        docker-compose up -d
        cd ..
        cd rabbitmq
        git pull origin master
        docker-compose up -d
        cd ..
        cd micro-live-streaming
        git pull origin master
        docker-compose up -d
        cd ..
    fi
done" > .git/hooks/post-receive
