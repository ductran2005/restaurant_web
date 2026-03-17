@echo off
REM Script khởi động ứng dụng với Docker cho Windows

echo ========================================
echo Starting Restaurant Management System
echo ========================================
echo.

REM Kiểm tra Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker chua duoc cai dat!
    echo Vui long cai Docker Desktop tu: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose chua duoc cai dat!
    pause
    exit /b 1
)

echo [OK] Docker da duoc cai dat
echo.

REM Hỏi người dùng chọn môi trường
echo Chon moi truong deploy:
echo 1) Development (Local PostgreSQL)
echo 2) Production (Supabase)
echo.
set /p choice="Nhap lua chon (1 hoac 2): "

if "%choice%"=="1" (
    echo.
    echo [INFO] Building va starting voi Local PostgreSQL...
    docker-compose up -d --build
) else if "%choice%"=="2" (
    echo.
    set /p password="Nhap Supabase password: "
    set SUPABASE_PASSWORD=%password%
    echo [INFO] Building va starting voi Supabase...
    docker-compose -f docker-compose.supabase.yml up -d --build
) else (
    echo [ERROR] Lua chon khong hop le!
    pause
    exit /b 1
)

echo.
echo [INFO] Doi ung dung khoi dong...
timeout /t 10 /nobreak >nul

echo.
echo ========================================
echo [SUCCESS] Ung dung da duoc khoi dong!
echo ========================================
echo.
echo Truy cap: http://localhost:8080
echo.
echo Xem logs: docker-compose logs -f webapp
echo Dung: docker-compose down
echo.
pause
