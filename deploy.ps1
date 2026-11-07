# StageMap — Deploy sur Vercel sans Git, sans CLI
# Usage : clic droit > Execute avec PowerShell
#    OU : Set-Location "C:\Users\arthu\Downloads\stagemap" ; .\deploy.ps1

$ErrorActionPreference = "Stop"

# Aller dans le dossier du script
Set-Location -Path $PSScriptRoot

Write-Host ""
Write-Host "  StageMap - Deploy Vercel" -ForegroundColor Magenta
Write-Host "  ------------------------" -ForegroundColor Magenta
Write-Host ""

# Verifier les fichiers
if (-not (Test-Path "index.html")) { Write-Host "index.html introuvable dans $PSScriptRoot" -ForegroundColor Red; Read-Host "Entree pour fermer"; exit 1 }
if (-not (Test-Path "companies.js")) { Write-Host "companies.js introuvable" -ForegroundColor Red; Read-Host "Entree pour fermer"; exit 1 }

# Recuperer le token (depuis env var ou prompt)
$token = $env:VERCEL_TOKEN
if (-not $token) {
    Write-Host "1. Va sur https://vercel.com/account/tokens" -ForegroundColor Cyan
    Write-Host "2. Create Token -> Nom libre, Scope 'Full Account', Expiration au choix"
    Write-Host "3. Copie le token qui apparait (il ne s'affiche qu'une fois)"
    Write-Host ""
    $sec = Read-Host "Colle ton Vercel token ici" -AsSecureString
    $token = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}
if (-not $token) { Write-Host "Token vide, arret." -ForegroundColor Red; exit 1 }

# Encoder les fichiers en base64
Write-Host "Encodage des fichiers..." -ForegroundColor DarkGray
$indexB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$PSScriptRoot\index.html"))
$companiesB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$PSScriptRoot\companies.js"))

# Construire le payload Vercel
$payload = @{
    name = "stagemap"
    target = "production"
    files = @(
        @{ file = "index.html"; data = $indexB64; encoding = "base64" }
        @{ file = "companies.js"; data = $companiesB64; encoding = "base64" }
    )
    projectSettings = @{
        framework = $null
        buildCommand = $null
        installCommand = $null
        outputDirectory = $null
        devCommand = $null
        rootDirectory = $null
    }
} | ConvertTo-Json -Depth 10 -Compress

Write-Host "Envoi a l'API Vercel..." -ForegroundColor DarkGray
try {
    $resp = Invoke-RestMethod -Uri "https://api.vercel.com/v13/deployments" `
        -Method POST `
        -Headers @{ Authorization = "Bearer $token" } `
        -ContentType "application/json" `
        -Body $payload
} catch {
    Write-Host ""
    Write-Host "ECHEC du deploiement :" -ForegroundColor Red
    Write-Host $_.ErrorDetails.Message
    Write-Host ""
    Read-Host "Entree pour fermer"
    exit 1
}

$url = "https://$($resp.url)"
Write-Host ""
Write-Host "  DEPLOYE !" -ForegroundColor Green
Write-Host "  $url" -ForegroundColor Green
Write-Host ""
Write-Host "  Le deploiement finit son build en 10-20 secondes." -ForegroundColor DarkGray
Write-Host "  AVANT de te connecter en Google sur le site :" -ForegroundColor Yellow
Write-Host "  - Va sur https://console.cloud.google.com/apis/credentials"
Write-Host "  - Ton OAuth Client -> Authorized JavaScript origins"
Write-Host "  - Ajoute : $url"
Write-Host ""

# Essayer d'ouvrir dans le navigateur
Start-Process $url

Read-Host "Entree pour fermer"
