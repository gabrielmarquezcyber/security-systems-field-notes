# Initial Commit Plan

## Goal

Publish the first structurally complete version of `security-systems-field-notes` as a reviewer-facing proof archive.

## Expected local path

```text
C:\GitHub\security-systems-field-notes
```

## Files included in first commit

```text
README.md
reviewer-proof-map.md
docs/README.md
docs/01-making-competence-inspectable.md
essays/making-competence-inspectable.md
frameworks/selection-environment-proof-map.md
security-notes/README.md
ai-trust-architecture/README.md
reality-calibration/README.md
checklists/public-proof-artifact-checklist.md
linkedin-drafts/making-competence-inspectable-linkedin-post.md
references/source-notes.md
evidence/README.md
scripts/validate-public-repo.ps1
setup-windows-c-drive.md
initial-commit-plan.md
.gitignore
```

## Pre-commit validation

Run from PowerShell inside the repo folder:

```powershell
cd C:\GitHub\security-systems-field-notes
powershell -ExecutionPolicy Bypass -File .\scripts\validate-public-repo.ps1
git diff --check
```

## Commit commands

```powershell
cd C:\GitHub\security-systems-field-notes
git init -b main
git status --short
git add .
git commit -m "docs: create security systems field notes archive"
git remote add origin https://github.com/gabrielmarquezcyber/security-systems-field-notes.git
git remote -v
git push -u origin main
```

If `git init -b main` fails, use:

```powershell
git init
git branch -M main
```

Then continue with `git add .`.

## Browser check after push

Open the GitHub repo page and verify:

```text
README renders cleanly
reviewer-proof-map.md opens
Docs Index opens
Essay opens
Source Notes opens
LinkedIn draft opens
No broken layout appears
No private/internal construction language appears
```
