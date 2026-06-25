$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "Repairing encoding only. No editorial rewrite will be applied..."

$repo = (Get-Location).Path
$readmePath = Join-Path $repo "README.md"
$spanishPath = Join-Path $repo "making-competence-inspectable-es.md"

if (-not (Test-Path $readmePath)) { throw "README.md not found." }
if (-not (Test-Path $spanishPath)) { throw "making-competence-inspectable-es.md not found." }

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Win1252 = [System.Text.Encoding]::GetEncoding(1252)
$Utf8 = [System.Text.Encoding]::UTF8

# Mojibake marker chars, built by code point so this script stays ASCII-only.
$Marker_C3 = [string][char]0x00C3  # mojibake lead for accented chars
$Marker_C2 = [string][char]0x00C2  # mojibake lead for inverted punctuation
$Marker_E2 = [string][char]0x00E2  # mojibake lead for smart punctuation
$Replacement = [string][char]0xFFFD

function Repair-MojibakeLine([string]$line) {
    $current = $line
    for ($i = 0; $i -lt 3; $i++) {
        if (-not ($current.Contains($Marker_C3) -or $current.Contains($Marker_C2) -or $current.Contains($Marker_E2))) {
            break
        }
        try {
            $bytes = $Win1252.GetBytes($current)
            $decoded = $Utf8.GetString($bytes)
            if ($decoded -eq $current) { break }
            $current = $decoded
        }
        catch {
            break
        }
    }
    return $current
}

function Normalize-Punctuation([string]$text) {
    # Convert smart punctuation to stable ASCII to avoid future quote/apostrophe mojibake.
    $text = $text.Replace([string][char]0x201C, '"')
    $text = $text.Replace([string][char]0x201D, '"')
    $text = $text.Replace([string][char]0x2018, "'")
    $text = $text.Replace([string][char]0x2019, "'")
    $text = $text.Replace([string][char]0x2013, '-')
    $text = $text.Replace([string][char]0x2014, '--')
    $text = $text.Replace([string][char]0x2026, '...')
    return $text
}

function Repair-File([string]$path) {
    $raw = [System.IO.File]::ReadAllText($path, $Utf8)
    $raw = $raw -replace "`r`n", "`n"
    $raw = $raw -replace "`r", "`n"
    $lines = $raw -split "`n", -1
    $fixedLines = foreach ($line in $lines) {
        Normalize-Punctuation (Repair-MojibakeLine $line)
    }
    $fixed = [string]::Join("`n", $fixedLines)
    [System.IO.File]::WriteAllText($path, $fixed, $Utf8NoBom)
}

Repair-File $readmePath
Repair-File $spanishPath

# Remove old scaffolding if any failed earlier patch left it around. Do not touch the approved two-file content.
if (Test-Path ".\articles") { Remove-Item ".\articles" -Recurse -Force }
if (Test-Path ".\about.md") { Remove-Item ".\about.md" -Force }
if (Test-Path ".\sources") { Remove-Item ".\sources" -Recurse -Force }
if (Test-Path ".\social") { Remove-Item ".\social" -Recurse -Force }
if (Test-Path ".\series") { Remove-Item ".\series" -Recurse -Force }

Write-Host "Encoding repair written. Running validation..."

$publicDocs = @(
    (Get-Item ".\README.md"),
    (Get-Item ".\making-competence-inspectable-es.md")
)

$linkPattern = [regex]'\[[^\]]+\]\(([^)]+)\)'
$missing = @()
foreach ($doc in $publicDocs) {
    $content = Get-Content $doc.FullName -Raw -Encoding UTF8
    foreach ($match in $linkPattern.Matches($content)) {
        $target = $match.Groups[1].Value.Trim()
        if ($target -match '^(https?:|mailto:|#)') { continue }
        if ($target.Contains('#')) { $target = $target.Split('#')[0] }
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        $resolved = Join-Path $doc.DirectoryName $target
        if (-not (Test-Path $resolved)) {
            $missing += "$($doc.FullName) -> $target"
        }
    }
}
if ($missing.Count -gt 0) {
    Write-Host "Missing markdown links:"
    $missing | ForEach-Object { Write-Host $_ }
    throw "Markdown local-link check failed."
}
Write-Host "Markdown local-link check: clean"

$encodingHits = @()
foreach ($doc in $publicDocs) {
    $lines = Get-Content $doc.FullName -Encoding UTF8
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Contains($Marker_C3) -or $line.Contains($Marker_C2) -or $line.Contains($Marker_E2) -or $line.Contains($Replacement)) {
            $encodingHits += "$($doc.FullName):$($i + 1): suspicious encoding marker :: $line"
        }
    }
}
if ($encodingHits.Count -gt 0) {
    Write-Host "Encoding/mojibake scan found matches:"
    $encodingHits | Select-Object -First 40 | ForEach-Object { Write-Host $_ }
    throw "Encoding/mojibake scan failed."
}
Write-Host "Encoding/mojibake scan: clean"

Write-Host "Encoding-only validation complete."

git add README.md making-competence-inspectable-es.md
if (Test-Path ".\articles") { git add -A articles }
if (Test-Path ".\about.md") { git add -A about.md }
if (Test-Path ".\sources") { git add -A sources }
if (Test-Path ".\social") { git add -A social }
if (Test-Path ".\series") { git add -A series }
# Stage deletions created by earlier failed patches too.
git add -A

$status = git status --short
$status | ForEach-Object { Write-Host $_ }
if ($status) {
    git commit -m "fix: repair markdown encoding"
    git push
} else {
    Write-Host "No encoding changes to commit."
}

Remove-Item ".\apply-v*.ps1" -ErrorAction SilentlyContinue
Write-Host "Encoding-only repair complete. No editorial rewrite was applied."
