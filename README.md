# DeepSeek Vision Bridge

让 DeepSeek 模型在 Claude Code 中拥有视觉识别能力。

当你使用 DeepSeek 作为 Claude Code 的后端模型时，DeepSeek 无法理解图片。这个项目通过一个 Skill + 脚本的组合，自动将你拖入的图片发送给支持视觉的模型（如 GPT-4o、Claude、Gemini），然后把文字描述返回给 DeepSeek——让它"看见"图片。

---

## 效果演示

```
用户：拖入一张商品图 → "怎么把这张图P得更有质感？"

DeepSeek：（自动调视觉API识别图片）
→ 识别到白色三角梅盆栽 + 阳台 + 午后阳光
→ 给出光影重塑、高频锐化、调色定调等PS步骤
```

全程不需要手动输入任何命令，拖入图片即可。

---

## 工作原理

```
用户拖入图片
    ↓
Claude Code 将图片路径写入 prompt：[Image: source: D:\photo.png]
    ↓
Skill 指令告诉 DeepSeek："看到图片路径就调用 vision 脚本"
    ↓
vision.ps1 → base64 编码图片 → 调 OpenAI/Claude/Gemini API
    ↓
返回文字描述给 DeepSeek
    ↓
DeepSeek 基于描述回答用户（就像亲眼看到了图片）
```

---

## 快速开始

### 1. 安装

**Windows（PowerShell）：**
```powershell
git clone https://github.com/sleepppnow/deepseek-vision-skill.git
cd deepseek-vision-skill
powershell -ExecutionPolicy Bypass -File install.ps1
```

**macOS / Linux：**
```bash
git clone https://github.com/sleepppnow/deepseek-vision-skill.git
cd deepseek-vision-skill
bash install.sh
```

### 2. 配置 API Key

编辑 `~/.claude/scripts/vision-config.json`，填入你的视觉模型 API Key：

```json
{
    "provider": "openai",
    "model": "gpt-4o-mini",
    "api_key": "sk-你的密钥",
    "api_url": "",
    "max_tokens": 1000
}
```

> 没有 OpenAI Key？支持 Anthropic Claude、Google Gemini、或任何 OpenAI 兼容的中转 API。<br>
> 详见 [docs/providers.md](docs/providers.md)

### 3. 重启 Claude Code

重启或输入 `/hooks` 刷新配置。

### 4. 拖入一张图片

在任何对话中拖入图片，DeepSeek 会自动识别。

---

## 支持的视觉模型

| 提供商 | 配置值 | 推荐模型 | 费用 |
|--------|--------|---------|------|
| OpenAI | `openai` | `gpt-4o-mini` | ~¥0.15/张 |
| Anthropic | `anthropic` | `claude-haiku-4-5` | ~$0.001/张 |
| Google | `google` | `gemini-2.5-flash` | 有免费额度 |
| OpenAI 兼容中转 | `openai` + `api_url` | 任意 | 按中转方定价 |

---

## 项目结构

```
deepseek-vision-skill/
├── README.md                        # 本文件
├── LICENSE                          # MIT 许可证
├── CHANGELOG.md                     # 版本更新记录
├── install.ps1                      # Windows 一键安装脚本
├── install.sh                       # macOS/Linux 一键安装脚本
├── .gitignore
│
├── src/
│   └── vision.ps1                   # 核心脚本：图片编码 + API 调用
│
├── config/
│   └── vision-config.example.json   # 配置文件模板
│
├── skill/
│   └── vision.md                    # Claude Code Skill 指令
│
└── docs/
    └── providers.md                 # 各提供商详细配置指南
```

### 各文件职责

| 文件 | 安装位置 | 职责 |
|------|---------|------|
| `src/vision.ps1` | `~/.claude/scripts/` | 核心引擎：接收图片路径，调用视觉 API，返回文字 |
| `skill/vision.md` | `~/.claude/skills/` | 告诉 DeepSeek 何时以及如何调用 vision.ps1 |
| `config/vision-config.example.json` | `~/.claude/scripts/vision-config.json` | API Key 和模型选择（安装后需手动编辑） |

---

## 配置详解

### vision-config.json 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `provider` | 是 | 视觉模型提供商：`openai` / `anthropic` / `google` |
| `model` | 是 | 具体模型名称 |
| `api_key` | 是 | API 密钥 |
| `api_url` | 否 | 自定义 API 端点（留空用官方地址） |
| `max_tokens` | 否 | 返回文本最大长度，默认 1000 |

### 使用第三方中转 API

如果你使用国内中转服务（如 AIHub、OpenRouter 等），只需设置 `api_url` 为完整端点：

```json
{
    "provider": "openai",
    "model": "gpt-4o-mini",
    "api_key": "sk-your-proxy-key",
    "api_url": "https://your-proxy.com/v1/chat/completions",
    "max_tokens": 1000
}
```

---

## 常见问题

### Q: 重启后 Skill 不生效？

在 Claude Code 中输入 `/hooks` 打开面板，然后 Esc 退出。这会让 Claude Code 重新扫描 `~/.claude/skills/` 目录。

### Q: 提示 "[vision ERROR] API error..."

检查 `~/.claude/scripts/vision-config.json`：
- `api_key` 是否正确？
- `api_url` 是否包含完整路径（如 `/v1/chat/completions`）？
- 网络是否能访问 API 端点？

### Q: 图片拖入没反应？

确认：
1. 使用的是 Claude Code **终端版**（不是网页版）
2. 图片文件没有被移动/删除（路径必须可访问）
3. 权限已配置：`~/.claude/settings.json` 中包含 `PowerShell(*vision.ps1*)`

### Q: 支持哪些图片格式？

PNG、JPG、GIF、WebP、BMP。其他格式会自动按 PNG 处理。

### Q: 每张图要花多少钱？

GPT-4o-mini 约 600×600 图片约 ¥0.1-0.2/张。详见各模型官方定价。

---

## 如何贡献

1. Fork 本项目
2. 创建功能分支：`git checkout -b feature/xxx`
3. 提交更改：`git commit -m 'Add xxx'`
4. 推送：`git push origin feature/xxx`
5. 创建 Pull Request

### 迭代方向（欢迎贡献）

- [ ] 支持更多视觉模型（通义千问、文心一言等）
- [ ] 支持图片压缩（减少 API 费用）
- [ ] 支持多图并行处理
- [ ] 添加图片缓存（相同图片不重复调用 API）
- [ ] npm / Homebrew 安装方式
- [ ] 支持 Claude Code 内联图片粘贴（当前仅拖入）

---

## 许可证

MIT © 2026 DeepSeek Vision Bridge Contributors

详见 [LICENSE](LICENSE)
