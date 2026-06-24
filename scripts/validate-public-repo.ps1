$ErrorActionPreference = "Stop"

Write-Host "Running public repo validation..."

$repoRoot = Resolve-Path "."
Set-Location $repoRoot

$publicDocs = @()
$pathsToScan = @(
    ".\README.md",
    ".\reviewer-proof-map.md",
    ".\docs\*.md",
    ".\essays\*.md",
    ".\frameworks\*.md",
    ".\security-notes\*.md",
    ".\ai-trust-architecture\*.md",
    ".\reality-calibration\*.md",
    ".\checklists\*.md",
    ".\linkedin-drafts\*.md",
    ".\references\*.md",
    ".\evidence\*.md"
)

foreach ($path in $pathsToScan) {
    $publicDocs += Get-ChildItem -Path $path -File -ErrorAction SilentlyContinue
}

$missingLinks = @()

foreach ($doc in $publicDocs) {
    $text = Get-Content $doc.FullName -Raw

    [regex]::Matches($text, '\]\(([^)]+)\)') | ForEach-Object {
        $link = $_.Groups[1].Value.Trim()

        if ($link -match '^(https?:|mailto:|#)' -or $link -eq '') {
            return
        }

        $cleanLink = ($link -split '#')[0]
        if ($cleanLink -eq '') {
            return
        }

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

foreach ($doc in $publicDocs) {
    $text = Get-Content $doc.FullName -Raw

    [regex]::Matches($text, '<img src="([^"]+)"') | ForEach-Object {
        $link = $_.Groups[1].Value.Trim()

        if ($link -match '^(https?:)' -or $link -eq '') {
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

$scanTerms = @(
    "suggested",
    "Suggested",
    "if available",
    "when added",
    "TODO",
    "placeholder",
    "room completion",
    "Room-aligned",
    "room-aligned",
    "badge",
    "flag content",
    "flag guide",
    "answer dump",
    "copy-paste",
    "copy/paste",
    "what to say",
    "school",
    "assignment",
    "WGU",
    "homework",
    "performance assessment",
    "TryHackMe",
    "I completed",
    "ChatGPT helped",
    "AI generated",
    "the assistant suggested"
)

$scanHits = @()

foreach ($doc in $publicDocs) {
    $lines = Get-Content $doc.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($term in $scanTerms) {
            if ([string]::IsNullOrWhiteSpace($term)) {
                continue
            }

            if ($lines[$i].Contains($term)) {
                $scanHits += "$($doc.FullName):$($i + 1): $term :: $($lines[$i])"
            }
        }
    }
}

if ($scanHits.Count -eq 0) {
    Write-Host "Public-safety text scan: clean"
} else {
    Write-Host "Public-safety scan found matches:"
    $scanHits
    throw "Public-safety scan failed."
}

$encodingTerms = @(
    [string][char]0x00E2,
    [string][char]0x00C3,
    [string][char]0xFFFD
)

$encodingHits = @()

foreach ($doc in $publicDocs) {
    $lines = Get-Content $doc.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($term in $encodingTerms) {
            if ([string]::IsNullOrWhiteSpace($term)) {
                continue
            }

            if ($lines[$i].Contains($term)) {
                $encodingHits += "$($doc.FullName):$($i + 1): suspicious encoding character :: $($lines[$i])"
            }
        }
    }
}

if ($encodingHits.Count -eq 0) {
    Write-Host "Encoding/mojibake scan: clean"
} else {
    Write-Host "Encoding/mojibake scan found matches:"
    $encodingHits
    throw "Encoding/mojibake scan failed."
}

Write-Host "Public repo validation complete."
