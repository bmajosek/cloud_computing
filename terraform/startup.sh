#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io git postgresql-client

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone repo
git clone https://github.com/bmajosek/cloud_computing.git
cd cloud_computing

# Create .env file with DB connection info
cat <<EOF > .env
DB_HOST=${cloudsql_private_ip}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF

# Verify the file was created
echo "----- .env contents -----"
cat .env
echo "-------------------------"

# Start services
sudo docker-compose up -d --build