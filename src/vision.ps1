# vision.ps1 — DeepSeek Vision Bridge
# Send image to vision-capable model, return text description
# Usage: vision.ps1 -ImagePath "D:\path\to\image.png"

param(
    [Parameter(Mandatory = $true)]
    [string]$ImagePath,
    [string]$Prompt = "Please describe this image in detail. Include all text, objects, colors, layout, and any notable details."
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "vision-config.json"

if (-not (Test-Path $configFile)) {
    Write-Output "[vision ERROR] Config file not found: $configFile"
    exit 1
}
try {
    $config = Get-Content $configFile -Raw -Encoding utf8 | ConvertFrom-Json
} catch {
    Write-Output "[vision ERROR] Config JSON parse error: $($_.Exception.Message)"
    exit 1
}

if (-not (Test-Path $ImagePath)) {
    Write-Output "[vision ERROR] Image file not found: $ImagePath"
    exit 1
}

$ext = [System.IO.Path]::GetExtension($ImagePath).ToLower()
$mimeMap = @{
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".webp" = "image/webp"
    ".bmp"  = "image/bmp"
}
$mimeType = if ($mimeMap.ContainsKey($ext)) { $mimeMap[$ext] } else { "image/png" }

try {
    $imageBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $ImagePath))
    $base64 = [Convert]::ToBase64String($imageBytes)
} catch {
    Write-Output "[vision ERROR] Failed to read image: $($_.Exception.Message)"
    exit 1
}

$provider = if ($config.provider) { $config.provider.ToLower() } else { "openai" }
$model = if ($config.model) { $config.model } else { "gpt-4o-mini" }
$apiUrl = if ($config.api_url) { $config.api_url } else { "" }
$maxTokens = if ($config.max_tokens) { $config.max_tokens } else { 1000 }

try {
    # -- OpenAI / OpenAI-compatible --
    if ($provider -eq "openai") {
        $body = @{
            model      = $model
            messages   = @(
                @{
                    role    = "user"
                    content = @(
                        @{ type = "text"; text = $Prompt },
                        @{
                            type      = "image_url"
                            image_url = @{
                                url    = "data:$mimeType;base64,$base64"
                                detail = "auto"
                            }
                        }
                    )
                }
            )
            max_tokens = $maxTokens
        } | ConvertTo-Json -Depth 10 -Compress

        $uri = if ($apiUrl) { $apiUrl } else { "https://api.openai.com/v1/chat/completions" }
        $headers = @{
            "Content-Type"  = "application/json"
            "Authorization" = "Bearer $($config.api_key)"
        }

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 120
        Write-Output $response.choices[0].message.content
        exit 0
    }

    # -- Anthropic Claude --
    if ($provider -eq "anthropic") {
        $body = @{
            model      = $model
            max_tokens = $maxTokens
            messages   = @(
                @{
                    role    = "user"
                    content = @(
                        @{ type = "text"; text = $Prompt },
                        @{
                            type   = "image"
                            source = @{
                                type       = "base64"
                                media_type = $mimeType
                                data       = $base64
                            }
                        }
                    )
                }
            )
        } | ConvertTo-Json -Depth 10 -Compress

        $uri = if ($apiUrl) { $apiUrl } else { "https://api.anthropic.com/v1/messages" }
        $headers = @{
            "Content-Type"      = "application/json"
            "x-api-key"         = $config.api_key
            "anthropic-version" = "2023-06-01"
        }

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 120
        Write-Output $response.content[0].text
        exit 0
    }

    # -- Google Gemini --
    if ($provider -eq "google") {
        $uri = if ($apiUrl) { $apiUrl } else { "https://generativelanguage.googleapis.com/v1beta/models/$model`:generateContent?key=$($config.api_key)" }

        $body = @{
            contents = @(
                @{
                    parts = @(
                        @{ text = $Prompt },
                        @{
                            inlineData = @{
                                mimeType = $mimeType
                                data     = $base64
                            }
                        }
                    )
                }
            )
        } | ConvertTo-Json -Depth 10 -Compress

        $headers = @{
            "Content-Type" = "application/json"
        }

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 120
        Write-Output $response.candidates[0].content.parts[0].text
        exit 0
    }

    Write-Output "[vision ERROR] Unsupported provider: $provider. Use: openai, anthropic, google"
    exit 1

} catch {
    $errMsg = $_.Exception.Message
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $errBody = $reader.ReadToEnd()
            Write-Output "[vision ERROR] API error: $errBody"
        } catch {
            Write-Output "[vision ERROR] API call failed: $errMsg"
        }
    } else {
        Write-Output "[vision ERROR] $errMsg"
    }
    exit 1
}
