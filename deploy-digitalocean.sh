#!/bin/bash
set -e

# Cài Docker nếu chưa có
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker installed. Please logout and login again, then run this script again."
    exit 0
fi

# Cài Docker Compose nếu chưa có
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Deploy
docker-compose -f docker-compose.supabase.yml down || true
docker-compose -f docker-compose.supabase.yml build --no-cache
docker-compose -f docker-compose.supabase.yml up -d

echo "Deployed at http://$(curl -s ifconfig.me):8080"
