$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$envAzdPath = Join-Path $scriptDir "../../.azure/${env:AZURE_ENV_NAME}/.env"

if (!(Test-Path $envAzdPath -PathType Leaf)) {
    # azd env file does not exist so there is nothing to do

    return
}

# Remove any env vars that were most likely set by provisioning the infrastructure - the infrastructure has been removed so they are no longer relevant

$keysToKeep = @("AZURE_ENV_NAME", "AZURE_LOCATION", "AZURE_SUBSCRIPTION_ID", "AZURE_TENANT_ID")

$envVars = @{}

Get-Content $envAzdPath | ForEach-Object {
    $key, $value = $_ -split '=', 2

    if ($keysToKeep -contains $key) {
        $envVars[$key] = $value
    }
}

$envVars.Keys | Sort-Object | ForEach-Object {
    "$_=$($envVars[$_])"
} | Out-File $envAzdPath
