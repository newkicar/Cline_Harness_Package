#Requires -Version 5.1
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$speckitDir = Join-Path $Root '.clinerules/workflows/speckit'
$outPath = Join-Path $Root '.specify/integrations/cline.manifest.json'

$files = @{}
Get-ChildItem -LiteralPath $speckitDir -Filter '*.md' | ForEach-Object {
    $rel = '.clinerules/workflows/speckit/' + $_.Name
    $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLower()
    $files[$rel] = $hash
}

$manifest = [ordered]@{
    integration  = 'cline'
    version      = '0.11.9.dev0'
    installed_at = (Get-Date).ToUniversalTime().ToString('o')
    files        = $files
}

$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $outPath -Encoding UTF8
Write-Host "Updated $outPath ($($files.Count) files)"
