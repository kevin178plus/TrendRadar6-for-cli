@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ==========================================
echo   TrendRadar OpenClaw 自动安装脚本
echo   版本：6.0.0
echo ==========================================
echo.

REM 检查Python
echo [1/5] 检查Python环境...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未找到Python，请先安装 Python 3.10+
    echo 下载地址：https://www.python.org/downloads/
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✓ Python版本：%PYTHON_VERSION%

REM 检查Python版本是否 >= 3.10
python -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)"
if %errorlevel% neq 0 (
    echo ❌ 错误：Python版本过低，需要 3.10+
    pause
    exit /b 1
)

echo.

REM 安装UV
echo [2/5] 检查UV包管理器...
where uv >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在安装UV包管理器...
    pip install uv --quiet
    if %errorlevel% neq 0 (
        echo ❌ UV安装失败
        pause
        exit /b 1
    )
)
echo ✓ UV已安装

echo.

REM 安装依赖
echo [3/5] 安装项目依赖...
uv sync
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)
echo ✓ 依赖安装完成

echo.

REM 验证配置文件
echo [4/5] 验证配置文件...
if not exist "config\config.yaml" (
    echo ❌ 错误：缺少配置文件 config\config.yaml
    pause
    exit /b 1
)
if not exist "config\frequency_words.txt" (
    echo ❌ 错误：缺少配置文件 config\frequency_words.txt
    pause
    exit /b 1
)
if not exist "config\timeline.yaml" (
    echo ❌ 错误：缺少配置文件 config\timeline.yaml
    pause
    exit /b 1
)
echo ✓ 配置文件完整

echo.

REM 显示部署完成信息
echo [5/5] 部署完成！
echo.
echo ==========================================
echo   🎉 TrendRadar 安装成功！
echo ==========================================
echo.
echo 📝 下一步操作：
echo   1. 编辑配置文件：config\config.yaml
echo   2. 配置通知渠道（飞书/钉钉/Telegram等）
echo   3. 运行：uv run python -m trendradar
echo.
echo 🚀 快速启动命令：
echo   uv run python -m trendradar
echo.
echo 📚 更多信息请查看：README.md
echo.
pause