#!/bin/bash
# =============================================
# SCRIPT DEPLOY NHANH - chạy trên server
# Cách dùng: bash redeploy.sh
# =============================================

set -e
echo "======================================"
echo "   RESTAURANT WEB - REDEPLOY SCRIPT   "
echo "======================================"

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[1/4] Pulling latest code from GitHub...${NC}"
git pull origin main

echo -e "${YELLOW}[2/4] Stopping current containers...${NC}"
docker compose -f docker-compose.supabase.yml down || true

echo -e "${YELLOW}[3/4] Building Docker image (this takes 3-5 minutes)...${NC}"
docker compose -f docker-compose.supabase.yml build --no-cache

echo -e "${YELLOW}[4/4] Starting containers...${NC}"
docker compose -f docker-compose.supabase.yml up -d

echo ""
echo -e "${GREEN}======================================"
echo "   DEPLOY COMPLETED SUCCESSFULLY!    "
echo "======================================"
echo -e "Site: https://testcode.click${NC}"
echo ""
echo "Checking logs (Ctrl+C to stop)..."
sleep 3
docker compose -f docker-compose.supabase.yml logs --tail=30 webapp
