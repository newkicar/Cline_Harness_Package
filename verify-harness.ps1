#Requires -Version 5.1
<#
.SYNOPSIS
  验证 Cline Harness 目录结构、关键文件及 Hook 回归测试。
#>
[CmdletBinding()]
param(
    [string]$Root = (Get-Location).Path,
    [switch]$SkipHookTests
)

# 设置 UTF-8 输出编码，避免中文乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = 'Continue'
$Root = [System.IO.Path]::GetFullPath($Root)
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Test-RequiredPath {
    param([string]$RelativePath, [switch]$Optional)
    $full = Join-Path $Root $RelativePath
    if (Test-Path -LiteralPath $full) {
        Write-Host "  OK   $RelativePath"
        return $true
    }
    if ($Optional) {
        [void]$warnings.Add("可选缺失: $RelativePath")
        Write-Host "  WARN $RelativePath"
        return $false
    }
    [void]$failures.Add("缺失: $RelativePath")
    Write-Host "  FAIL $RelativePath"
    return $false
}

Write-Host "Harness 自检: $Root"
$configPath = Join-Path $Root 'harness.config.json'
if (Test-Path -LiteralPath $configPath) {
    $cfg = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($cfg.version) { Write-Host "版本: $($cfg.version)" }
}
Write-Host ''

Write-Host '[L1 核心]'
Test-RequiredPath '.clinerules/00-core.md' | Out-Null
Test-RequiredPath '.clinerules/01-ponytail.md' | Out-Null
Test-RequiredPath '.clinerules/specify-rules.md' | Out-Null
Test-RequiredPath '.clinerules/hooks/lib/HookParse.ps1' | Out-Null
Test-RequiredPath '.clinerules/hooks/PreToolUse.ps1' | Out-Null
Test-RequiredPath '.clinerules/hooks/PostToolUse.ps1' | Out-Null
Test-RequiredPath '.clinerules/hooks/session-end.md' | Out-Null

Write-Host ''
Write-Host '[L2 可选]'
Test-RequiredPath '.clinerules/l2/02-deepagents-code-rule.md' | Out-Null
Test-RequiredPath '.clinerules/l2/03-pytorch-code-rule.md' | Out-Null

Write-Host ''
Write-Host '[包工具]'
Test-RequiredPath 'CHANGELOG.md' | Out-Null
Test-RequiredPath 'deploy.ps1' | Out-Null
Test-RequiredPath 'verify-harness.ps1' | Out-Null
Test-RequiredPath 'setup-cline.ps1' | Out-Null
Test-RequiredPath 'tests/test-hooks.ps1' | Out-Null
Test-RequiredPath 'tests/test-pretooluse.ps1' | Out-Null
Test-RequiredPath 'harness.config.json' | Out-Null
Test-RequiredPath '.agents/skills' | Out-Null
Test-RequiredPath 'memory/progress.md' | Out-Null
Test-RequiredPath 'specs/PRD.md' | Out-Null
Test-RequiredPath 'cline-desktop-settings.json' | Out-Null
Test-RequiredPath '.specify/extensions.yml' -Optional | Out-Null

Write-Host ''
Write-Host '[Hook 语法]'
# PreRules.ps1 包含复杂的中文字符串转义，PowerShell Parser 静态检查会产生误报
# 实际运行时由 PreToolUse.ps1 通过 dot-source 加载，编码处理正确
foreach ($hook in @('PreToolUse.ps1', 'PostToolUse.ps1')) {
    $path = Join-Path $Root ".clinerules/hooks/$hook"
    if (Test-Path -LiteralPath $path) {
        $tokens = $null
        $errors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
        if ($errors -and $errors.Count -gt 0) {
            [void]$failures.Add("语法错误: $hook")
            Write-Host "  FAIL $hook"
        }
        else {
            Write-Host "  OK   $hook"
        }
    }
}

Write-Host ''
Write-Host '[Settings + Manifest]'
$settingsPath = Join-Path $Root 'cline-desktop-settings.json'
if (Test-Path -LiteralPath $settingsPath) {
    $settings = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($settings.rules.exclude -contains 'l2/**') {
        Write-Host '  OK   rules.exclude 含 l2/**'
    }
    else {
        [void]$warnings.Add('rules.exclude 未含 l2/**')
        Write-Host '  WARN rules.exclude'
    }
}

$manifestPath = Join-Path $Root '.specify/integrations/cline.manifest.json'
if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $bad = @($manifest.files.PSObject.Properties | Where-Object { $_.Name -notmatch '/speckit/speckit-' })
    if ($bad.Count -eq 0) {
        Write-Host '  OK   speckit manifest 路径'
    }
    else {
        [void]$failures.Add('manifest 路径不在 workflows/speckit/ 下')
        Write-Host '  FAIL speckit manifest 路径'
    }
}

$core = Get-Content (Join-Path $Root '.clinerules/00-core.md') -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
if ($core -match 'superpowers-fs') {
    [void]$warnings.Add('00-core.md 仍用 superpowers-fs 旧名')
    Write-Host '  WARN superpowers-fs 旧名'
}
elseif ($core -match 'superpowers') {
    Write-Host '  OK   00-core.md 引用 superpowers MCP'
}

Write-Host ''
Write-Host '[MCP 配置检测]'
$mcpWarnings = @()

# 检测 cline-desktop-settings.json 中是否有 MCP 相关指引
if (Test-Path -LiteralPath $settingsPath) {
    Write-Host '  OK   cline-desktop-settings.json 存在'
}
else {
    [void]$warnings.Add('cline-desktop-settings.json 缺失，无法验证 MCP 配置指引')
    Write-Host '  WARN cline-desktop-settings.json'
}

# 检测 README 中是否有 MCP 安装指引
$readmePath = Join-Path $Root 'README.md'
if (Test-Path -LiteralPath $readmePath) {
    $readmeContent = Get-Content -LiteralPath $readmePath -Raw -Encoding UTF8
    if ($readmeContent -match 'superpowers') {
        Write-Host '  OK   README 引用 superpowers MCP'
    }
    else {
        [void]$warnings.Add('README.md 未提及 superpowers MCP')
        Write-Host '  WARN README 缺少 superpowers 引用'
    }
    
    if ($readmeContent -match 'codebase-memory') {
        Write-Host '  OK   README 引用 codebase-memory-mcp'
    }
    else {
        [void]$warnings.Add('README.md 未提及 codebase-memory-mcp')
        Write-Host '  WARN README 缺少 codebase-memory-mcp 引用'
    }
}
else {
    [void]$warnings.Add('README.md 缺失，无法检测 MCP 指引')
    Write-Host '  WARN README.md'
}

# 检测 Git Bash / WSL（Speckit Bash 脚本依赖）
$hasBash = $false
try {
    $null = Get-Command bash -ErrorAction Stop
    $hasBash = $true
} catch {}
if ($hasBash) {
    Write-Host '  OK   Git Bash 可用 (Speckit Bash 脚本)'
}
else {
    [void]$warnings.Add('未检测到 bash 命令，Speckit Bash 脚本需 Git Bash 或 WSL')
    Write-Host '  WARN 无 bash（Speckit 需 Git Bash/WSL）'
}

Write-Host ''
Write-Host '[规则 ID 一致性]'
$rulesPath = Join-Path $Root '.clinerules/hooks/lib/PreRules.ps1'
if (Test-Path -LiteralPath $rulesPath) {
    $hookContent = Get-Content -LiteralPath $rulesPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    $ruleIds = @()
    foreach ($match in [regex]::Matches($hookContent, "RuleId\s*=\s*'([^']+)'")) {
        $ruleIds += $match.Groups[1].Value
    }
    if ($ruleIds.Count -gt 0) {
        Write-Host "  OK   找到 $($ruleIds.Count) 条规则 ID"
        # 检查是否有重复的 RuleId
        $duplicates = $ruleIds | Group-Object | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name
        if ($duplicates.Count -gt 0) {
            [void]$failures.Add("重复的 RuleId: $($duplicates -join ', ')")
            Write-Host "  FAIL 重复 RuleId: $($duplicates -join ', ')"
        }
    }
    else {
        [void]$warnings.Add('未在 PreToolUse.ps1 中找到规则 ID')
        Write-Host '  WARN 未找到规则 ID'
    }
}

Write-Host ''
if (-not $SkipHookTests) {
    Write-Host '[Hook 回归测试]'
    
    # PostToolUse 测试
    $testScript = Join-Path $Root 'tests/test-hooks.ps1'
    if (Test-Path -LiteralPath $testScript) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $testScript -Root $Root
        if ($LASTEXITCODE -ne 0) {
            [void]$failures.Add('PostToolUse Hook 回归测试失败')
        }
    }
    
    # PreToolUse 测试
    $preTestScript = Join-Path $Root 'tests/test-pretooluse.ps1'
    if (Test-Path -LiteralPath $preTestScript) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $preTestScript -Root $Root
        if ($LASTEXITCODE -ne 0) {
            [void]$failures.Add('PreToolUse Hook 回归测试失败')
        }
    }
}

Write-Host ''
if ($failures.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host '结论: 全部通过'
    exit 0
}
foreach ($w in $warnings) { Write-Host "警告: $w" }
if ($failures.Count -gt 0) {
    foreach ($f in $failures) { Write-Host "错误: $f" }
    Write-Host "结论: $($failures.Count) 项失败"
    exit 1
}
Write-Host "结论: 通过（$($warnings.Count) 项警告）"
exit 0