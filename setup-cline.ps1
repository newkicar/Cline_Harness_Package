#Requires -Version 5.1
param(
    [string]$Root = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

$Root = [System.IO.Path]::GetFullPath($Root)
$settings = Join-Path $Root 'cline-desktop-settings.json'
$config = Join-Path $Root 'harness.config.json'

Write-Host ''
Write-Host '=========================================='
Write-Host ' Cline Harness - Setup Checklist'
Write-Host '=========================================='
Write-Host ''

if (Test-Path -LiteralPath $config) {
    $h = Get-Content -LiteralPath $config -Raw | ConvertFrom-Json
    Write-Host "Harness version: $($h.version)"
}

Write-Host ''
Write-Host '[1] Import Cline settings'
Write-Host "    File: $settings"
Write-Host '    In Cline: Settings -> import hooks, rules, skills, workflows from this JSON.'
Write-Host ''

Write-Host '[2] Enable MCP servers (Cline MCP settings, NOT in this folder)'
Write-Host '    - superpowers          (design + TDD)'
Write-Host '    - codebase-memory-mcp  (drift / CI / trace_path)'
Write-Host ''

Write-Host '[3] Optional: install ruff for PostToolUse Python lint'
Write-Host '    pip install ruff'
Write-Host ''

Write-Host '[4] Verify deployment'
Write-Host '    powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1'
Write-Host ''

if (Test-Path -LiteralPath $settings) {
    try {
        Start-Process notepad.exe -ArgumentList $settings
        Write-Host 'Opened cline-desktop-settings.json in Notepad for reference.'
    }
    catch {
        Write-Host 'Open cline-desktop-settings.json manually in Cline settings UI.'
    }
}

Write-Host ''
Write-Host 'See README.md for the full 5-minute guide.'
Write-Host 'Run scripts: powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-harness.ps1'
Write-Host ''
