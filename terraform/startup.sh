#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io git
git clone https://github.com/USERNAME/instagram-django-demo.git
cd instagram-django-demo
docker-compose up -d --build