#Requires -Version 5.1
param([string]$Root = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)))

$ErrorActionPreference = 'Stop'
$Root = [System.IO.Path]::GetFullPath($Root)
$lib = Join-Path $Root '.clinerules/hooks/lib/HookParse.ps1'
$failures = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { Write-Host "  OK   $Name"; return }
    Write-Host "  FAIL $Name"
    $script:failures++
}

. $lib

Write-Host "Hook tests: $Root"
Write-Host ''

Write-Host '[HookParse unit]'
$diff = @"
------- SEARCH
old
=======
path = "C:\Users\test"
+++++++ REPLACE
"@
$scan = Get-ScanTextFromDiff -Diff $diff
Assert-True ($scan -match 'C:\\Users') 'Get-ScanTextFromDiff extracts REPLACE section'

$repaired = Repair-HookJson -Raw '{"result":"bad \" stuff here","success":true}'
Assert-True ($repaired -match '"result":"","success"') 'Repair-HookJson strips bloated result'

$validJson = Get-Content (Join-Path $Root 'tests/fixtures/posttooluse-valid.json') -Raw
$ctx = Get-PostToolUseContext -InputJson $validJson
Assert-True ($ctx.toolName -eq 'replace_in_file') 'valid JSON parse toolName'
Assert-True ($ctx.scanText -match 'C:\\\\Users') 'valid JSON parse diff scanText'

$brokenJson = Get-Content (Join-Path $Root 'tests/fixtures/posttooluse-broken-result.json') -Raw
$ctxBroken = Get-PostToolUseContext -InputJson $brokenJson
Assert-True ($ctxBroken.parseFallback -or $ctxBroken.scanText -match 'C:\\\\temp') 'broken JSON fallback or repair'

Write-Host ''
Write-Host '[PostToolUse integration]'
$hook = Join-Path $Root '.clinerules/hooks/PostToolUse.ps1'
$samplePy = Join-Path $Root 'tests/fixtures/sample.py'
Set-Content -LiteralPath $samplePy -Value "x = 1`n" -Encoding UTF8 -NoNewline

$payload = @{
    postToolUse = @{
        toolName   = 'write_to_file'
        parameters = @{
            path    = $samplePy
            content = "api_key = 'sk-abcdefghijklmnopqrstuvwxyz1234567890ab'"
        }
    }
} | ConvertTo-Json -Compress -Depth 5

Push-Location $Root
try {
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    Assert-True ($out -match 'AUDIT-SEC-001') 'PostToolUse detects leaked secret pattern'
}
finally {
    Pop-Location
    Set-Content -LiteralPath $samplePy -Value "# test fixture`nx = 1`n" -Encoding UTF8
}

Write-Host ''
if ($failures -eq 0) {
    Write-Host "Hook tests: PASS"
    exit 0
}
Write-Host "Hook tests: FAIL ($failures)"
exit 1
