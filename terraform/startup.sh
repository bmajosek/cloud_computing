#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io git
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
git clone https://github.com/bmajosek/cloud_computing.git
cd cloud_computing
sudo docker-compose up -d --build