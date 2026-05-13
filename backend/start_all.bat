@echo off
echo Master Scan ishga tushmoqda...

:: Backend ishga tushirish
start "Master Scan Backend" cmd /k "cd /d D:\loyiha ind\backend && python run.py"

:: 5 soniya kutish (backend ishga tushguncha)
timeout /t 5 /nobreak

:: Ngrok ishga tushirish
start "Master Scan Ngrok" cmd /k "ngrok http 8000"

echo Hammasi ishga tushdi!
