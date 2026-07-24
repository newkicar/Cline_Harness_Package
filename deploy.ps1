#Requires -Version 5.1
<#
.SYNOPSIS
  将 Cline Harness 部署到目标项目根目录。

.DESCRIPTION
  拷贝 Harness 组件到 TargetDir，并按需启用 L2 领域规则。
  MCP（superpowers、codebase-memory-mcp）在 Cline 设置中单独配置，本脚本不处理。
  部署后自动在目标项目 .gitignore 中添加 Harness 文件排除规则。

.PARAMETER TargetDir
  目标项目根目录（默认：当前目录）

.PARAMETER L2
  启用的 L2 模块，逗号分隔：deepagents, pytorch

.PARAMETER Extras
  [已废弃] 扩展工作流已默认部署，此参数保留仅为向后兼容

.PARAMETER SkipSpeckit
  不拷贝 .specify/ 目录

.EXAMPLE
  .\deploy.ps1 -TargetDir D:\Projects\my-app -L2 deepagents,pytorch
#>
[CmdletBinding()]
param(
    [string]$TargetDir = (Get-Location).Path,
    [string]$L2 = '',
    [switch]$Extras,
    [switch]$SkipSpeckit
)

$ErrorActionPreference = 'Stop'
$SourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = [System.IO.Path]::GetFullPath($TargetDir)

$CopyItems = @(
    @{ Source = '.clinerules'; Required = $true },
    @{ Source = '.agents'; Required = $true },
    @{ Source = 'memory'; Required = $true },
    @{ Source = 'specs'; Required = $true },
    @{ Source = 'design'; Required = $true },
    @{ Source = 'harness.config.json'; Required = $true },
    @{ Source = 'cline-desktop-settings.json'; Required = $false }
)

function Copy-HarnessItem {
    param([string]$RelativePath, [string]$From, [string]$To)
    $src = Join-Path $From $RelativePath
    $dst = Join-Path $To $RelativePath
    if (-not (Test-Path -LiteralPath $src)) {
        throw "源路径不存在: $src"
    }
    $parent = Split-Path -Parent $dst
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    if (Test-Path -LiteralPath $src -PathType Container) {
        Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
    }
    else {
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
    Write-Host "  OK  $RelativePath"
}

Write-Host "Harness 部署 -> $TargetDir"
Write-Host ''

foreach ($item in $CopyItems) {
    Copy-HarnessItem -RelativePath $item.Source -From $SourceRoot -To $TargetDir
}

if (-not $SkipSpeckit) {
    Copy-HarnessItem -RelativePath '.specify' -From $SourceRoot -To $TargetDir
}
else {
    Write-Host '  SKIP .specify/ (-SkipSpeckit)'
}

# ===== L2 自动检测 =====
Write-Host ''
Write-Host '[L2 自动检测]'
$detectedL2 = @()
$targetFiles = Get-ChildItem -LiteralPath $TargetDir -Recurse -File -ErrorAction SilentlyContinue
foreach ($f in $targetFiles) {
    $content = $null
    try { $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
    if (-not $content) { continue }
    if ($f.Name -eq 'pyproject.toml' -and $content -match 'torch') {
        if ('pytorch' -notin $detectedL2) { $detectedL2 += 'pytorch' }
    }
    if ($content -match 'import\s+torch' -or $content -match 'from\s+torch') {
        if ('pytorch' -notin $detectedL2) { $detectedL2 += 'pytorch' }
    }
    if ($content -match 'create_deep_agent\(' -or $content -match 'github\.com/copilot-sdk') {
        if ('deepagents' -notin $detectedL2) { $detectedL2 += 'deepagents' }
    }
}

if ($detectedL2.Count -gt 0) {
    Write-Host '  [提示] 检测到以下项目特征，建议启用 L2 领域规则：'
    foreach ($l in $detectedL2) {
        Write-Host "    - $l"
    }
    Write-Host '  启用命令: deploy.ps1 -L2 ' + ($detectedL2 -join ',')
}
else {
    Write-Host '  [提示] 未检测到 L2 特征项目特征，无需启用 L2 领域规则。'
}

# ===== L2 配置化加载（新增）=====
# 如果用户指定了 -L2 参数，更新 harness.config.json 和 cline-desktop-settings.json
if ($L2) {
    Write-Host ''
    Write-Host '[L2 启用]'
    $modules = $L2 -split ',' | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ }
    $l2Root = Join-Path $TargetDir '.clinerules\l2'
    $configPath = Join-Path $TargetDir 'harness.config.json'
    $config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $enabledModules = @()
    
    foreach ($mod in $modules) {
        $rel = $config.l2.$mod
        if (-not $rel) {
            Write-Warning "未知 L2 模块: $mod（可选: deepagents, pytorch）"
            continue
        }
        
        # 传统方式：复制文件到根目录（向后兼容）
        $src = Join-Path $l2Root (Split-Path -Leaf $rel)
        $dstName = Split-Path -Leaf $rel
        $dst = Join-Path $TargetDir ".clinerules\$dstName"
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "  COPIED  $dstName → .clinerules/"
        
        # 新方式：更新 settings 中的 l2_enabled
        $enabledModules += $mod
    }
    
    if ($enabledModules.Count -gt 0) {
        # 更新 harness.config.json
        $config.enabledL2 = $enabledModules
        $config | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $configPath -Encoding UTF8
        
        # 更新 cline-desktop-settings.json 中的 l2_enabled
        $settingsPath = Join-Path $TargetDir 'cline-desktop-settings.json'
        if (Test-Path -LiteralPath $settingsPath) {
            $settings = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if (-not $settings.rules.l2_enabled) {
                $settings.rules | Add-Member -Name 'l2_enabled' -Value $enabledModules -MemberType 'NoteProperty'
            } else {
                $settings.rules.l2_enabled = $enabledModules
            }
            $settings | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $settingsPath -Encoding UTF8
            Write-Host "  UPDATED cline-desktop-settings.json rules.l2_enabled"
        }
        
        Write-Host ''
        Write-Host '  [提示] L2 规则已通过两种方式启用：'
        Write-Host '    1. 文件复制到 .clinerules/（向后兼容）'
        Write-Host '    2. settings.json 中 l2_enabled 配置更新'
    }
}

# ===== 自动添加 .gitignore 排除规则 =====
$gitignorePath = Join-Path $TargetDir '.gitignore'
$harnessExcludes = @(
    '# Cline Harness 文件（由 deploy.ps1 自动添加）',
    '.clinerules/',
    '.agents/',
    'memory/',
    'specs/',
    'design/',
    'harness.config.json',
    'cline-desktop-settings.json',
    ''
)

$needsAdding = $false
if (Test-Path -LiteralPath $gitignorePath) {
    $existing = Get-Content -LiteralPath $gitignorePath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $existing.Contains('.clinerules/') -or -not $existing.Contains('# Cline Harness')) {
        $needsAdding = $true
    }
}
else {
    $needsAdding = $true
}

if ($needsAdding) {
    $harnessExcludes -join "`n" | Add-Content -LiteralPath $gitignorePath -Encoding UTF8
    Write-Host ''
    Write-Host '[.gitignore] 已自动添加 Harness 文件排除规则'
}

# ===== -Extras 已废弃 =====
# 扩展工作流已默认包含在 .clinerules/ 部署中，-Extras 参数保留仅为向后兼容
if ($Extras) {
    Write-Host ''
    Write-Host '[Extras] 扩展工作流已默认部署，无需额外操作'
}

Write-Host ''
Write-Host '后续步骤:'
Write-Host '  1. 在 Cline 中导入 cline-desktop-settings.json（hooks / rules / skills / workflows）'
Write-Host '  2. 在 Cline MCP 设置中确认已安装 superpowers 与 codebase-memory-mcp'
Write-Host '  3. 可选: 项目内安装 ruff 以启用 PostToolUse lint'
Write-Host '  4. 运行: powershell -File .\setup-cline.ps1'
Write-Host '  5. 运行: powershell -File .\verify-harness.ps1'
