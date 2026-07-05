# 视觉模型提供商配置指南

## OpenAI（推荐）

最省心的选择，GPT-4o-mini 便宜且效果优秀。

```json
{
    "provider": "openai",
    "model": "gpt-4o-mini",
    "api_key": "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "api_url": "",
    "max_tokens": 1000
}
```

| 模型 | 价格（大约） | 适用 |
|------|-------------|------|
| `gpt-4o-mini` | ~¥0.15/张 | 日常识图，性价比最高 |
| `gpt-4o` | ~¥0.5/张 | 需要精确文字识别 |
| `gpt-4.1` | ~¥3/张 | 复杂图表分析 |

获取 Key: [platform.openai.com/api-keys](https://platform.openai.com/api-keys)

---

## 第三方中转 API

很多国内用户使用 OpenAI 格式的中转服务。只需设置 `api_url` 即可：

```json
{
    "provider": "openai",
    "model": "gpt-4o-mini",
    "api_key": "sk-your-proxy-key",
    "api_url": "https://your-proxy.com/v1/chat/completions",
    "max_tokens": 1000
}
```

只要 API 兼容 OpenAI 的 `/v1/chat/completions` 端点即可。

---

## Anthropic Claude

```json
{
    "provider": "anthropic",
    "model": "claude-haiku-4-5",
    "api_key": "sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "api_url": "",
    "max_tokens": 1000
}
```

| 模型 | 说明 |
|------|------|
| `claude-haiku-4-5` | 最快最便宜 |
| `claude-sonnet-5` | 图像理解最强 |

获取 Key: [console.anthropic.com](https://console.anthropic.com/)

---

## Google Gemini

有免费额度，适合轻度使用。

```json
{
    "provider": "google",
    "model": "gemini-2.5-flash",
    "api_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXX",
    "api_url": "",
    "max_tokens": 1000
}
```

| 模型 | 说明 |
|------|------|
| `gemini-2.5-flash` | 有免费层级 |
| `gemini-2.5-pro` | 最强推理 + 视觉 |

获取 Key: [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
