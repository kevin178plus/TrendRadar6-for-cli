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