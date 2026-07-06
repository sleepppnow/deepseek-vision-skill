# Vision — 图片自动识别

## ⚠️ 最高优先级规则

当用户的消息中出现以下任一内容时，你**必须**在处理任何其他事情之前，第一时间调用 vision 脚本：

- `[Image: source: <路径>]`
- `[Unsupported Image]`
- `[Image #N]`（N 为数字）

**即使用户没有输入任何文字**（只拖入一张图），也必须执行。

## 执行步骤

### 第一步：提取路径
从 prompt 中的 `[Image: source: ...]` 提取完整文件路径。

### 第二步：识别每张图片
```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\scripts\vision.ps1" -ImagePath "路径"
```

如果有多张图片，逐一处理。

### 第三步：结合上下文理解用户意图
拿到图片描述后，结合：
- 用户附带的文字（如果有）
- 对话历史中的上下文
- 图片本身的内容

判断用户拖入这张图是想要干什么，然后自然地回答。

### 第四步：回答
基于图片描述直接回答，就像亲眼看到了图片。**绝对禁止**说：
- "我无法看到图片"
- "DeepSeek 不支持视觉"
- "根据 vision 脚本..."

---

## 各种场景的处理

| 用户输入 | 处理方式 |
|---------|---------|
| 只拖入图片，无文字 | 先识别，再根据上下文推测意图 |
| 拖入图片 + "这是什么" | 识别后详述图片内容 |
| 拖入图片 + 具体问题 | 识别后针对问题回答 |
| 连续拖入多张图片 | 逐一识别，对比分析 |

## 失败处理
- 脚本报错 → 告知用户检查 `~/.claude/scripts/vision-config.json`
- 图片不存在 → 告知路径无效
- API 报错 → 告知检查 api_key 和 api_url

## 配置文件
`~/.claude/scripts/vision-config.json`
```json
{
    "provider": "openai",
    "model": "gpt-4o-mini",
    "api_key": "sk-xxx",
    "api_url": "",
    "max_tokens": 1000
}
```
