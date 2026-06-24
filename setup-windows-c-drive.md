# Windows C Drive Setup

## Target path

Use this local path:

```text
C:\GitHub\security-systems-field-notes
```

## Verify extraction

In File Explorer, confirm these files exist:

```text
C:\GitHub\security-systems-field-notes\README.md
C:\GitHub\security-systems-field-notes\reviewer-proof-map.md
C:\GitHub\security-systems-field-notes\docs\README.md
C:\GitHub\security-systems-field-notes\docs\01-making-competence-inspectable.md
C:\GitHub\security-systems-field-notes\essays\making-competence-inspectable.md
C:\GitHub\security-systems-field-notes\linkedin-drafts\making-competence-inspectable-linkedin-post.md
C:\GitHub\security-systems-field-notes\scripts\validate-public-repo.ps1
```

## Create the GitHub repo on the website

1. Sign in to GitHub as `gabrielmarquezcyber`.
2. Click the plus icon in the top-right.
3. Click **New repository**.
4. Owner: `gabrielmarquezcyber`.
5. Repository name: `security-systems-field-notes`.
6. Description: `Field notes on cybersecurity, AI trust architecture, security operations, selection environments, and operational systems.`
7. Visibility: **Public**.
8. Leave these unchecked:

```text
Add a README file
Add .gitignore
Choose a license
```

9. Click **Create repository**.

## Push from PowerShell

```powershell
cd C:\GitHub\security-systems-field-notes
powershell -ExecutionPolicy Bypass -File .\scripts\validate-public-repo.ps1
git init -b main
git status --short
git add .
git commit -m "docs: create security systems field notes archive"
git remote add origin https://github.com/gabrielmarquezcyber/security-systems-field-notes.git
git push -u origin main
```

If `git init -b main` fails:

```powershell
git init
git branch -M main
git add .
git commit -m "docs: create security systems field notes archive"
git remote add origin https://github.com/gabrielmarquezcyber/security-systems-field-notes.git
git push -u origin main
```
