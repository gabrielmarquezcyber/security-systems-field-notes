$ErrorActionPreference = "Stop"

Write-Host "Running public repo validation..."

$missingLinks = @()

Get-ChildItem . -Recurse -File -Include *.md | ForEach-Object {
  $doc = $_
  $text = Get-Content $doc.FullName -Raw

  [regex]::Matches($text, '\]\(([^)]+)\)') | ForEach-Object {
    $link = $_.Groups[1].Value

    if ($link -match '^(https?:|mailto:|#)' -or $link.Trim() -eq '') {
      return
    }

    $cleanLink = ($link -split '#')[0]
    $relativePath = $cleanLink -replace '/', '\'
    $target = Join-Path $doc.Directory.FullName $relativePath

    if (-not (Test-Path $target)) {
      $missingLinks += "$($doc.FullName) -> $link"
    }
  }
}

if ($missingLinks.Count -eq 0) {
  Write-Host "Markdown local-link check: clean"
} else {
  Write-Host "Missing markdown links:"
  $missingLinks
  throw "Markdown local-link check failed."
}

$missingImages = @()

Get-ChildItem . -Recurse -File -Include *.md | ForEach-Object {
  $doc = $_
  $text = Get-Content $doc.FullName -Raw

  [regex]::Matches($text, '<img src="([^"]+)"') | ForEach-Object {
    $link = $_.Groups[1].Value

    if ($link -match '^(https?:)') {
      return
    }

    $relativePath = $link -replace '/', '\'
    $target = Join-Path $doc.Directory.FullName $relativePath

    if (-not (Test-Path $target)) {
      $missingImages += "$($doc.FullName) -> $link"
    }
  }
}

if ($missingImages.Count -eq 0) {
  Write-Host "Embedded image-link check: clean"
} else {
  Write-Host "Missing embedded image links:"
  $missingImages
  throw "Embedded image-link check failed."
}

$scanPaths = @("README.md", "reviewer-proof-map.md", "docs\*.md", "essays\*.md", "frameworks\*.md", "security-notes\*.md", "ai-trust-architecture\*.md", "reality-calibration\*.md")
$scanTerms = "—|–|â|�|suggested|Suggested|if available|when added|TODO|placeholder|room completion|Room-aligned|room-aligned|badge|flag content|flag guide|answer dump|copy-paste|copy/paste|what to say|school|assignment|WGU|homework|performance assessment|TryHackMe|I completed"
$scan = Select-String -Path $scanPaths -Pattern $scanTerms -ErrorAction SilentlyContinue

if ($scan) {
  $scan
  throw "Public-safety text scan found matches."
} else {
  Write-Host "Public-safety text scan: clean"
}

Write-Host "Validation complete."
