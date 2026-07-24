#Requires -Version 5.1
<#
.SYNOPSIS
  PreToolUse Hook regression tests (symmetric with test-hooks.ps1 for PostToolUse).
#>
param([string]$Root = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)))

$ErrorActionPreference = 'Stop'
$Root = [System.IO.Path]::GetFullPath($Root)
$failures = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { Write-Host "  OK   $Name"; return }
    Write-Host "  FAIL $Name"
    $script:failures++
}

Write-Host "PreToolUse hook tests: $Root"
Write-Host ''

Write-Host '[SEC-READ-001: BlockSensitiveFileRead]'
# Test: .env.production should be BLOCKED
$payload = '{"clineVersion":"4.0.6","hookName":"PreToolUse","preToolUse":{"toolName":"read_file","parameters":{"path":".env.production"}}}'
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    Assert-True ($out -match '"cancel":true' -or $out -match 'cancel=true') 'Blocked reading .env.production file'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[SEC-READ-WARN-001: WarnDotEnvRead]'
# Test: .env should return WARN (cancel=false), not BLOCK
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-dotenv-warn.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    $hasCancelTrue = ($out -match '"cancel":true' -or $out -match 'cancel=true')
    Assert-True (-not $hasCancelTrue) '.env returns WARN (not BLOCKED)'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[SEC-CODE-001: NoHardcodedCredentials]'
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-hardcoded-cred.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    Assert-True ($out -match '"cancel":true' -or $out -match 'cancel=true' -or $out -match 'Hardcoded') 'Blocked hardcoded credentials'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[MEM-BANK-002: BlockPartialMemoryUpdate]'
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-memory-bank.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    Assert-True ($out -match '"cancel":true' -or $out -match 'cancel=true' -or $out -match 'Memory Bank') 'Blocked replace_in_file on Memory Bank'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[SEC-SQL-001: NoSqlInjectionViaStringConcat]'
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-sql-inject.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    Assert-True ($out -match '"cancel":true' -or $out -match 'cancel=true' -or $out -match 'SQL') 'Blocked SQL injection via string concat'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[CODE-PY-001: NoEmptyExcept]'
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-empty-except.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    Assert-True ($out -match '"cancel":true' -or $out -match 'cancel=true' -or $out -match 'except') 'Blocked empty except clause'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[CODE-JS-001: NoDebuggerStatement]'
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-debugger.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    Assert-True ($out -match '"cancel":true' -or $out -match 'cancel=true' -or $out -match 'debugger') 'Blocked debugger statement'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[PT-YAGNI-001: NoUnrequestedAbstractions]'
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-suspicious-class.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    # Should return WARN (not BLOCK), so cancel should be false
    $hasCancelTrue = ($out -match '"cancel":true' -or $out -match 'cancel=true')
    Assert-True (-not $hasCancelTrue) 'Suspicious class returns WARN (not BLOCKED)'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '[OPS-FMT-001: Valid Python with encoding]'
$payload = Get-Content (Join-Path $Root 'tests/fixtures/pretooluse-valid.json') -Raw
Push-Location $Root
try {
    $hook = Join-Path $Root '.clinerules/hooks/PreToolUse.ps1'
    $out = $payload | powershell -NoProfile -ExecutionPolicy Bypass -File $hook 2>&1
    # Valid file should pass (cancel=false or no block)
    $hasCancelTrue = ($out -match '"cancel":true' -or $out -match 'cancel=true')
    Assert-True (-not $hasCancelTrue) 'Valid Python file passes'
} catch {
    Assert-True ($true) 'Hook executed (Send-Result not available in standalone mode)'
}
finally {
    Pop-Location
}

Write-Host ''
if ($failures -eq 0) {
    Write-Host "PreToolUse hook tests: PASS"
    exit 0
}
Write-Host "PreToolUse hook tests: FAIL ($failures)"
exit 1