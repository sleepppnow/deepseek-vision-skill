# DeepSeek Vision Bridge — Windows 一键安装脚本
# Run: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"
Write-Output "========================================="
Write-Output " DeepSeek Vision Bridge - 安装程序"
Write-Output "========================================="
Write-Output ""

$homeDir = $env:USERPROFILE
$scriptsDir = Join-Path $homeDir ".claude\scripts"
$skillsDir  = Join-Path $homeDir ".claude\skills"
$configDir  = $scriptsDir  # 配置文件和脚本放一起
$settingsFile = Join-Path $homeDir ".claude\settings.json"

# 创建目录
foreach ($dir in @($scriptsDir, $skillsDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force $dir | Out-Null
        Write-Output "创建目录: $dir"
    }
}

# 复制核心脚本
$srcScript = Join-Path $PSScriptRoot "src\vision.ps1"
$dstScript = Join-Path $scriptsDir "vision.ps1"
Copy-Item -Path $srcScript -Destination $dstScript -Force
Write-Output "安装: vision.ps1 -> $dstScript"

# 复制配置文件（如果不存在）
$srcConfig = Join-Path $PSScriptRoot "config\vision-config.example.json"
$dstConfig = Join-Path $configDir "vision-config.json"
if (-not (Test-Path $dstConfig)) {
    Copy-Item -Path $srcConfig -Destination $dstConfig
    Write-Output "安装: vision-config.json -> $dstConfig"
    Write-Output ">>> 请编辑此文件，填入你的 API Key <<<"
} else {
    Write-Output "跳过: vision-config.json 已存在"
}

# 复制 Skill 指令
$srcSkill = Join-Path $PSScriptRoot "skill\vision.md"
$dstSkill = Join-Path $skillsDir "vision.md"
Copy-Item -Path $srcSkill -Destination $dstSkill -Force
Write-Output "安装: vision.md -> $dstSkill"

# 添加权限到 settings.json
$permissionRules = @(
    "PowerShell(*vision.ps1*)",
    "Bash(*vision*)"
)

if (Test-Path $settingsFile) {
    try {
        $settings = Get-Content $settingsFile -Raw -Encoding utf8 | ConvertFrom-Json
    } catch {
        Write-Output "警告: settings.json 解析失败，跳过权限配置"
        $settings = $null
    }

    if ($settings) {
        if (-not $settings.permissions) {
            $settings | Add-Member -MemberType NoteProperty -Name "permissions" -Value @{ allow = @() }
        }
        if (-not $settings.permissions.allow) {
            $settings.permissions | Add-Member -MemberType NoteProperty -Name "allow" -Value @()
        }

        $existing = [System.Collections.ArrayList]::new($settings.permissions.allow)
        $added = $false
        foreach ($rule in $permissionRules) {
            if ($rule -notin $existing) {
                [void]$existing.Add($rule)
                Write-Output "添加权限: $rule"
                $added = $true
            }
        }

        if ($added) {
            $settings.permissions.allow = [array]$existing
            $settings | ConvertTo-Json -Depth 5 | Set-Content -Path $settingsFile -Encoding utf8
        } else {
            Write-Output "权限已配置，无需重复添加"
        }
    }
} else {
    Write-Output "settings.json 不存在，跳过权限配置（首次使用时会自动创建）"
}

Write-Output ""
Write-Output "========================================="
Write-Output " 安装完成！"
Write-Output "========================================="
Write-Output ""
Write-Output "下一步:"
Write-Output "1. 编辑 $dstConfig"
Write-Output "   填入你的视觉模型 API Key"
Write-Output ""
Write-Output "2. 重启 Claude Code 或输入 /hooks 刷新"
Write-Output ""
Write-Output "3. 拖入一张图片试试！"
Write-Output ""
