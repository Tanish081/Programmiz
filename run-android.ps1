param(
    [string]$DeviceId = "",
    [string]$WirelessEndpoint = ""
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$groqKeyFile = Join-Path $projectRoot ".groq_api_key"
$wirelessEndpointFile = Join-Path $projectRoot ".wireless_adb_endpoint"

function Get-GroqApiKey {
    if ($env:GROQ_API_KEY -and $env:GROQ_API_KEY.Trim().Length -gt 0) {
        return $env:GROQ_API_KEY.Trim()
    }

    if (Test-Path $groqKeyFile) {
        $fileValue = (Get-Content $groqKeyFile -Raw).Trim()
        if ($fileValue.Length -gt 0) {
            return $fileValue
        }
    }

    $enteredKey = Read-Host "Enter Groq API key once to save locally"
    $enteredKey = $enteredKey.Trim()
    if ($enteredKey.Length -eq 0) {
        throw "Groq API key is required."
    }

    Set-Content -Path $groqKeyFile -Value $enteredKey -NoNewline
    return $enteredKey
}

function Get-AdbPath {
    $fromSdk = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
    if (Test-Path $fromSdk) {
        return $fromSdk
    }

    $cmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    return $null
}

function Get-AndroidDevices {
    $raw = flutter devices --machine | Out-String
    if (-not $raw -or -not $raw.Trim().StartsWith("[")) {
        return @()
    }

    try {
        $devices = $raw | ConvertFrom-Json
        return @($devices | Where-Object {
            $_.targetPlatform -match "android" -or $_.id -match "^emulator-" -or $_.name -match "Android"
        })
    }
    catch {
        return @()
    }
}

function Resolve-TargetDevice {
    param(
        [string]$RequestedId,
        [string]$Endpoint,
        [string]$AdbPath
    )

    if ($RequestedId -and $RequestedId.Trim().Length -gt 0) {
        return $RequestedId.Trim()
    }

    $devices = Get-AndroidDevices
    if ($devices.Count -gt 0) {
        return $devices[0].id
    }

    if ($Endpoint -and $Endpoint.Trim().Length -gt 0 -and $AdbPath) {
        Write-Host "Trying wireless endpoint: $Endpoint"
        & $AdbPath connect $Endpoint | Out-Null
        $devices = Get-AndroidDevices
        if ($devices.Count -gt 0) {
            return $devices[0].id
        }
    }

    return ""
}

function Start-FlutterRun {
    param(
        [string]$ResolvedDeviceId,
        [string]$ApiKey
    )

    flutter run -d $ResolvedDeviceId --dart-define=GROQ_API_KEY=$ApiKey
}

Push-Location $projectRoot

try {
    $groqApiKey = Get-GroqApiKey
    $adb = Get-AdbPath

    if ($WirelessEndpoint -and $WirelessEndpoint.Trim().Length -gt 0) {
        Set-Content -Path $wirelessEndpointFile -Value $WirelessEndpoint.Trim() -NoNewline
    }

    $savedEndpoint = ""
    if (Test-Path $wirelessEndpointFile) {
        $savedEndpoint = (Get-Content $wirelessEndpointFile -Raw).Trim()
    }

    $targetDevice = Resolve-TargetDevice -RequestedId $DeviceId -Endpoint $savedEndpoint -AdbPath $adb

    if (-not $targetDevice) {
        Write-Host "No Android device detected."
        Write-Host "If using wireless debugging, run once with:"
        Write-Host "  .\\run-android.ps1 -WirelessEndpoint <ip:port>"
        Write-Host "Then this script will reuse the saved endpoint automatically."
        exit 1
    }

    Write-Host "Running app on $targetDevice"
    Start-FlutterRun -ResolvedDeviceId $targetDevice -ApiKey $groqApiKey
}
finally {
    Pop-Location
}
