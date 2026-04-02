param(
    [string]$AvdId = "Pixel_6",
    [string]$EmulatorId = "emulator-5554"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $projectRoot

try {
    Write-Host "Launching emulator: $AvdId"
    flutter emulators --launch $AvdId | Out-Null

    Start-Sleep -Seconds 12

    $devices = flutter devices | Out-String
    if ($devices -notmatch [regex]::Escape($EmulatorId)) {
        $adb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
        if (Test-Path $adb) {
            Write-Host "Restarting ADB and re-checking devices..."
            & $adb kill-server | Out-Null
            & $adb start-server | Out-Null
            Start-Sleep -Seconds 5
            $devices = flutter devices | Out-String
        }
    }

    if ($devices -notmatch [regex]::Escape($EmulatorId)) {
        Write-Host "Emulator '$EmulatorId' not detected."
        Write-Host "Try opening Android Studio Device Manager and start '$AvdId' manually."
        exit 1
    }

    Write-Host "Running app on $EmulatorId"
    flutter run -d $EmulatorId
}
finally {
    Pop-Location
}
