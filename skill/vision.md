# DeepSeek Vision Bridge Skill

当 DeepSeek 用户拖入图片时，自动调用第三方视觉模型 API 获取图片文字描述。

## 触发条件

当看到以下模式时，**立即**处理图片，禁止说"我无法看到图片"：

- `[Image: source: <文件路径>]`
- `[Unsupported Image]` 配合 `[Image #N]` 占位符
- 用户说"这张图""看图""识别""图片里有什么"

## 操作步骤

### 1. 提取图片路径
从 `[Image: source: D:\path\to\image.png]` 中取路径。

### 2. 调用 Vision 脚本
```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\scripts\vision.ps1" -ImagePath "提取到的路径"
```

如果用户有具体问题（如"图片里的文字是什么？"），可传递自定义提示：
```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\scripts\vision.ps1" -ImagePath "路径" -Prompt "用户的问题"
```

### 3. 处理返回结果
- **成功返回文字描述** → 基于该描述直接回答用户，就像你亲眼看到了图片
- **报错含 "Config file not found"** → 告诉用户配置文件缺失
- **报错含 "API"** → 告诉用户检查 `~/.claude/scripts/vision-config.json` 中的 api_key

### 4. 回答风格
- 直接基于图片描述回答，**不要**说"根据 vision 脚本的返回..."
- 不要把脚本调用过程展示给用户
- 图片中有文字就逐字引用

## 配置
`~/.claude/scripts/vision-config.json`：
```json
{
    "provider": "openai",
    "model": "gpt-4o-mini",
    "api_key": "sk-xxx",
    "api_url": "https://your-proxy.com/v1/chat/completions",
    "max_tokens": 1000
}
```
