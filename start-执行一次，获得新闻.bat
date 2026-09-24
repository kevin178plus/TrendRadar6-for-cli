@echo off
chcp 936 >nul

echo ============================================================
echo   TrendRadar 执行一次，马上获取新闻，然后退出
echo ============================================================
echo.

REM 检查虚拟环境
if not exist ".venv\Scripts\python.exe" (
    echo [x][错误] 虚拟环境未找到
    echo 请先运行 setup-windows.bat 或 setup-windows-en.bat 进行部署
    echo.
    pause
    exit /b 1
)



python -m trendradar

pause
