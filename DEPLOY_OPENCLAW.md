# TrendRadar OpenClaw 自动部署指南

## 📦 部署准备

### 方案说明
将项目打包为ZIP，上传到HTTP服务器，OpenClaw下载并自动部署。

### ZIP打包清单

**必需文件：**
```
TrendRadar-mod-for-ks1/
├── pyproject.toml          # 项目配置
├── requirements.txt        # 依赖列表
├── README.md              # 使用说明
├── version                # 版本号
├── install-openclaw.bat   # OpenClaw自动安装脚本（新增）
├── trendradar/            # 主程序包
├── mcp_server/            # MCP服务器
└── config/                # 配置文件
    ├── config.yaml
    ├── frequency_words.txt
    └── timeline.yaml
```

**排除文件：**
- `.git/`, `.venv/`, `__pycache__/`
- `.pytest_cache/`, `.iflow/`
- `output/`, `uv.lock`
- `_信息关注和推送/`, `_image/`

### ZIP打包命令（PowerShell）
```powershell
# 在项目根目录执行
Compress-Archive -Path @(
    'pyproject.toml',
    'requirements.txt',
    'README.md',
    'version',
    'install-openclaw.bat',
    'trendradar',
    'mcp_server',
    'config'
) -DestinationPath TrendRadar-6.0.0-openclaw.zip -Force
```

---

## 🤖 OpenClaw 部署提示词

```
请帮我部署 TrendRadar 热点新闻聚合工具到当前服务器。

## 📥 下载项目
请从以下URL下载项目ZIP文件：
http://peter.shdic.com/tmp/TrendRadar-6.0.0-openclaw.zip

下载到：合适的位置

## 📦 解压并安装
1. 解压ZIP文件到目标目录
2. 进入项目目录
3. 运行安装脚本：install-openclaw.bat（Windows）或 install-openclaw.sh（Linux）

## ⚙️ 配置说明
安装完成后，需要编辑以下配置文件：

### config/config.yaml（主配置）
- 平台选择：启用需要的热榜平台（默认11个）
- 通知渠道：配置webhook URL（飞书/钉钉/Telegram等）
- AI配置：如果需要AI分析，配置AI_API_KEY和AI_MODEL

### config/frequency_words.txt（关键词）
添加您关注的关键词，每行一个

### config/timeline.yaml（调度配置）
配置定时任务执行时间（默认：每30分钟）

## 🚀 启动服务
安装完成后，运行以下命令启动：

### Windows:
uv run python -m trendradar

### Linux/Mac:
./.venv/bin/python -m trendradar

## ✅ 验证部署
1. 检查日志输出，确认无错误
2. 等待30分钟，查看是否收到通知推送
3. 如果配置了AI分析，检查AI分析结果

## 📚 核心功能
- 全网热点聚合（11个平台：今日头条、百度、微博、知乎等）
- RSS订阅源支持
- 多渠道推送（飞书、钉钉、Telegram、邮件等9种）
- AI智能分析（支持DeepSeek、OpenAI等）
- MCP AI分析服务器（17种AI工具）

## 🔧 系统要求
- Python 3.10+
- 网络连接（访问热榜平台）
- 可选：AI API密钥（如需AI功能）

## 📞 遇到问题？
如果遇到安装失败，请提供：
1. 错误信息截图
2. 操作系统版本
3. Python版本（python --version）
```

---

## 🔧 install-openclaw.bat（Windows自动安装脚本）

```batch
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
```

---

## 🔧 install-openclaw.sh（Linux/Mac自动安装脚本）

```bash
#!/bin/bash

set -e

echo "=========================================="
echo "  TrendRadar OpenClaw 自动安装脚本"
echo "  版本：6.0.0"
echo "=========================================="
echo ""

# 检查Python
echo "[1/5] 检查Python环境..."
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误：未找到Python3，请先安装 Python 3.10+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo "✓ Python版本：$PYTHON_VERSION"

# 检查Python版本是否 >= 3.10
if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)"; then
    echo "❌ 错误：Python版本过低，需要 3.10+"
    exit 1
fi

echo ""

# 安装UV
echo "[2/5] 检查UV包管理器..."
if ! command -v uv &> /dev/null; then
    echo "正在安装UV包管理器..."
    pip3 install uv --quiet
fi
echo "✓ UV已安装"

echo ""

# 安装依赖
echo "[3/5] 安装项目依赖..."
uv sync
echo "✓ 依赖安装完成"

echo ""

# 验证配置文件
echo "[4/5] 验证配置文件..."
if [ ! -f "config/config.yaml" ]; then
    echo "❌ 错误：缺少配置文件 config/config.yaml"
    exit 1
fi
if [ ! -f "config/frequency_words.txt" ]; then
    echo "❌ 错误：缺少配置文件 config/frequency_words.txt"
    exit 1
fi
if [ ! -f "config/timeline.yaml" ]; then
    echo "❌ 错误：缺少配置文件 config/timeline.yaml"
    exit 1
fi
echo "✓ 配置文件完整"

echo ""

# 显示部署完成信息
echo "[5/5] 部署完成！"
echo ""
echo "=========================================="
echo "  🎉 TrendRadar 安装成功！"
echo "=========================================="
echo ""
echo "📝 下一步操作："
echo "  1. 编辑配置文件：config/config.yaml"
echo "  2. 配置通知渠道（飞书/钉钉/Telegram等）"
echo "  3. 运行：uv run python -m trendradar"
echo ""
echo "🚀 快速启动命令："
echo "  uv run python -m trendradar"
echo ""
echo "📚 更多信息请查看：README.md"
echo ""
```

---

## 📝 配置文件示例

### config/config.yaml（最小配置示例）

```yaml
# 平台配置
platforms:
  toutiao: true      # 今日头条
  baidu: true        # 百度热搜
  weibo: true        # 微博
  zhihu: true        # 知乎
  douyin: false      # 抖音（关闭示例）

# 通知配置（至少配置一个）
notification:
  # 飞书机器人（推荐）
  feishu:
    enabled: true
    webhook_url: "https://open.feishu.cn/open-apis/bot/v2/hook/xxxxxxxx"

  # 钉钉机器人
  dingtalk:
    enabled: false
    webhook_url: "https://oapi.dingtalk.com/robot/send?access_token=xxxxxxxx"

  # Telegram机器人
  telegram:
    enabled: false
    bot_token: "xxxxxxxx"
    chat_id: "xxxxxxxx"

# AI配置（可选）
ai:
  enabled: false
  provider: "deepseek"
  api_key: ""
  model: "deepseek-chat"
```

### config/frequency_words.txt（关键词示例）

```
人工智能
AI
Python
技术
开发
```

---

## ✅ 部署验证清单

- [ ] ZIP文件已上传到HTTP服务器
- [ ] OpenClaw能够下载ZIP文件
- [ ] 安装脚本执行成功
- [ ] 配置文件已编辑
- [ ] 通知渠道已配置
- [ ] 服务启动成功
- [ ] 收到首次推送通知（等待30分钟）

---

## 🆘 常见问题

### Q1: Python版本检查失败
**解决**：安装 Python 3.10+
- Windows: https://www.python.org/downloads/
- Linux: `sudo apt install python3.10` 或 `yum install python3.10`

### Q2: UV安装失败
**解决**：使用pip安装
```bash
pip install uv
```

### Q3: 依赖安装失败
**解决**：检查网络连接，或使用国内镜像
```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple uv
```

### Q4: 配置文件找不到
**解决**：确保ZIP包含config目录和所有配置文件

### Q5: 启动后没有推送
**解决**：
1. 检查通知渠道配置是否正确
2. 检查网络连接
3. 查看日志输出：`uv run python -m trendradar --verbose`

---

## 📞 技术支持

如遇到问题，请提供：
1. 错误信息截图
2. 操作系统版本
3. Python版本（`python --version`）
4. 安装日志输出

---

**版本**：6.0.0  
**更新日期**：2026-03-02