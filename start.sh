#!/bin/bash

# Script khởi động ứng dụng với Docker

echo "🚀 Starting Restaurant Management System..."
echo ""

# Kiểm tra Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker chưa được cài đặt!"
    echo "Vui lòng cài Docker từ: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose chưa được cài đặt!"
    exit 1
fi

echo "✅ Docker đã được cài đặt"
echo ""

# Hỏi người dùng chọn môi trường
echo "Chọn môi trường deploy:"
echo "1) Development (Local PostgreSQL)"
echo "2) Production (Supabase)"
read -p "Nhập lựa chọn (1 hoặc 2): " choice

case $choice in
    1)
        echo ""
        echo "📦 Building và starting với Local PostgreSQL..."
        docker-compose up -d --build
        ;;
    2)
        echo ""
        read -p "Nhập Supabase password: " -s password
        echo ""
        export SUPABASE_PASSWORD=$password
        echo "📦 Building và starting với Supabase..."
        docker-compose -f docker-compose.supabase.yml up -d --build
        ;;
    *)
        echo "❌ Lựa chọn không hợp lệ!"
        exit 1
        ;;
esac

echo ""
echo "⏳ Đợi ứng dụng khởi động..."
sleep 10

echo ""
echo "✅ Ứng dụng đã được khởi động!"
echo ""
echo "🌐 Truy cập: http://localhost:8080"
echo ""
echo "📊 Xem logs: docker-compose logs -f webapp"
echo "🛑 Dừng: docker-compose down"
echo ""
