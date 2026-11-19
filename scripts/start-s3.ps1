# Démarre le stockage objet S3 (SeaweedFS) en local, sans Docker.
# Cherche weed.exe dans le PATH, sinon dans tools\weed.exe.
# Ports : S3 8333 (utilisé par l'API) ; volume 8081 (8080 est réservé à l'API).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$weed = (Get-Command weed -ErrorAction SilentlyContinue).Source
if (-not $weed -and (Test-Path "$root\tools\weed.exe")) { $weed = "$root\tools\weed.exe" }
if (-not $weed) { throw "weed.exe introuvable : voir README.md (etape 2)." }

$data = Join-Path $root ".local\s3-data"
New-Item -ItemType Directory -Force -Path $data | Out-Null
Write-Host "[s3] SeaweedFS sur http://localhost:8333 (donnees : $data)" -ForegroundColor Cyan
# Tous les arguments sont entre guillemets : PowerShell 5.1 coupe sinon "-ip=127.0.0.1" au premier point.
& $weed server "-dir=$data" "-s3" "-s3.config=$root\scripts\s3-dev.json" `
  "-ip=127.0.0.1" "-volume.port=8081" "-master.volumeSizeLimitMB=256" "-volume.max=0"
