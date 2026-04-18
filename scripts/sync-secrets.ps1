# Secret Synchronization Script for ClipWise
# Loads keys from .dev.vars and ensures they exist and have latest versions in GCP Secret Manager

$PROJECT_ID = "fasionwood"
$ENV_FILE = ".dev.vars"

# 1. Load keys from .dev.vars
if (!(Test-Path $ENV_FILE)) {
    Write-Error "Could not find $ENV_FILE"
    exit 1
}

$secrets = @{}
Get-Content $ENV_FILE | ForEach-Object {
    if ($_ -match "^([^=]+)=(.*)$") {
        $key = $Matches[1].Trim()
        $val = $Matches[2].Trim()
        $secrets[$key] = $val
    }
}

Write-Host "=== Syncing Secrets to GCP Project: $PROJECT_ID ==="

foreach ($key in $secrets.Keys) {
    $val = $secrets[$key]
    
    # Check if secret exists
    $exists = gcloud secrets list --filter="name~$key" --project=$PROJECT_ID --format="value(name)"
    
    if (-not $exists) {
        Write-Host "Creating secret: $key"
        gcloud secrets create $key --replication-policy="automatic" --project=$PROJECT_ID --quiet
    } else {
        Write-Host "Secret already exists: $key"
    }

    # Add new version
    Write-Host "Adding version for: $key"
    $val | gcloud secrets versions add $key --data-file=- --project=$PROJECT_ID --quiet
}

Write-Host "=== Secret Sync Complete ==="
