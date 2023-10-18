function Remove-Quotes {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$value,
        [string]$quoteChar = '"'
    )

    if ($value.StartsWith($quoteChar) -and $value.EndsWith($quoteChar)) {
        return $value.Substring(1, $value.Length - 2)
    }

    return $value
}

function Read-EnvVars {
    param(
        [Parameter(Mandatory = $true)]
        [string]$path
    )

    $envVars = @{}

    if (!(Test-Path $path -PathType Leaf)) {
        # File does not exist so there is nothing to do

        return $envVars
    }

    $content = Get-Content -raw $path | ConvertFrom-StringData

    $content.GetEnumerator() | Foreach-Object {
        $key, $value = $_.Name, $_.Value

        if (($null -eq $value) -or ($value -eq "")) {
            $envVars[$key] = $null
        } else {
            $value = Remove-Quotes -value $value -quoteChar '"'
            $value = Remove-Quotes -value $value -quoteChar "'"

            $envVars[$key] = $value
        }
    }

    return $envVars
}

function Read-AzdEnvVars {
    $azdEnv = (azd env get-values)

    $envVars = @{}

    $azdEnv | ForEach-Object {
        $entry = $_

        if ($null -eq $entry -or $entry -eq "" -or $entry.Contains("=") -eq $false) {
            return
        }

        $key, $value = $entry -split '=', 2

        if ($key -eq "" -or $key.Contains(" ") -eq $true) {
            return
        }

        if (($null -eq $value) -or ($value -eq "")) {
            $envVars[$key] = $null
        } else {
            $value = Remove-Quotes -value $value -quoteChar '"'
            $value = Remove-Quotes -value $value -quoteChar "'"

            $envVars[$key] = $value
        }
    }

    return $envVars
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$envAzdPath = Join-Path $scriptDir "../../.azure/${env:AZURE_ENV_NAME}/.env"

$envAzd = if ($null -eq $env:AZURE_ENV_NAME) { Read-AzdEnvVars } else { Read-EnvVars -path $envAzdPath }

# Output info required for domain verification
Write-Host "=== Container apps domain verification ==="
Write-Host "Static IP: $($envAzd.AZURE_CONTAINER_STATIC_IP)"
Write-Host "FQDN: $($envAzd.AZURE_WEB_APP_FQDN)"
Write-Host "Verification code: $($envAzd.AZURE_CONTAINER_DOMAIN_VERIFICATION_CODE)"
