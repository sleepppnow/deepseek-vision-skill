# Changelog

## [0.2.0] - 2026-07-05

### Added
- 支持 Anthropic Claude 视觉模型
- 支持 Google Gemini 视觉模型
- 支持自定义 API 端点（中转/代理）
- 一键安装脚本 `install.ps1`（Windows）和 `install.sh`（macOS/Linux）
- 提供商配置指南 `docs/providers.md`
- 完整 README 文档

### Fixed
- PowerShell 5.1 兼容性（`switch` → `if/else`）
- UTF-8 编码问题导致脚本解析失败
- JSON 配置文件中非法注释导致的解析错误

### Changed
- 项目结构重构：源码、配置、Skill 分离
- 配置文件模板化，不包含真实 Key

## [0.1.0] - 2026-07-05

### Added
- 核心视觉脚本 `vision.ps1`，支持 OpenAI GPT-4o 系列
- Claude Code Skill 指令 `vision.md`
- `[Image: source: ...]` 模式自动检测
- 用户拖入图片自动触发识别
