#!/usr/bin/env bash
# DeepSeek Vision Bridge — macOS/Linux 一键安装脚本
# Run: bash install.sh

set -e

echo "========================================="
echo " DeepSeek Vision Bridge - 安装程序"
echo "========================================="
echo ""

HOME_DIR="$HOME"
SCRIPTS_DIR="$HOME_DIR/.claude/scripts"
SKILLS_DIR="$HOME_DIR/.claude/skills"
SETTINGS_FILE="$HOME_DIR/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 创建目录
mkdir -p "$SCRIPTS_DIR" "$SKILLS_DIR"

# 复制核心脚本
cp "$SCRIPT_DIR/src/vision.ps1" "$SCRIPTS_DIR/vision.ps1"
echo "安装: vision.ps1 -> $SCRIPTS_DIR/vision.ps1"

# 复制配置文件
if [ ! -f "$SCRIPTS_DIR/vision-config.json" ]; then
    cp "$SCRIPT_DIR/config/vision-config.example.json" "$SCRIPTS_DIR/vision-config.json"
    echo "安装: vision-config.json -> $SCRIPTS_DIR/vision-config.json"
    echo ">>> 请编辑此文件，填入你的 API Key <<<"
else
    echo "跳过: vision-config.json 已存在"
fi

# 复制 Skill 指令
cp "$SCRIPT_DIR/skill/vision.md" "$SKILLS_DIR/vision.md"
echo "安装: vision.md -> $SKILLS_DIR/vision.md"

echo ""
echo "========================================="
echo " 安装完成！"
echo "========================================="
echo ""
echo "下一步:"
echo "1. 编辑 $SCRIPTS_DIR/vision-config.json"
echo "   填入你的视觉模型 API Key"
echo ""
echo "2. 重启 Claude Code 或输入 /hooks 刷新"
echo ""
echo "3. 拖入一张图片试试！"
echo ""
