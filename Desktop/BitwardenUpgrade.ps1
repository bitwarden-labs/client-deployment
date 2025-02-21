<# 
    Bitwarden Upgrade Script
    =========================
    
    This script upgrades Bitwarden **only if a different version is given in the installer path**.
    It logs the old and new versions and updates the configuration.

    Default Behavior:
    - Uses `InstalledPath` to locate the installed version.
    - If `data.json` exists, it updates or replaces it based on `DataJsonMode`.
    - If Bitwarden is not installed, a data.json file will be created with the set params.
    - Either provide the params on run, or set below. 
    - Please comment/uncomment the desired `Region` and `BaseUrl` settings.

#>

param (
    [string]$LogFolder = "$env:USERPROFILE\Downloads",
    [string]$InstallerPath = "$env:USERPROFILE\Downloads\Bitwarden-Installer-2025.1.3.exe",
    [string]$InstalledPath = "C:\Program Files\Bitwarden\Bitwarden.exe",
    [string]$DataJsonPath = "$env:APPDATA\Bitwarden\data.json",
    [string]$SourceJsonPath = "$env:USERPROFILE\Downloads\data.json",
    [string]$DataJsonMode = "Update",  # Options: Update, Replace, None
    [string]$AutoUpdate = "No",
    [string]$EnableLogging = "Yes",
    [int]$Verbosity = 0,  # 0 = Only critical logs, 1 = Detailed logs
    [string]$Region = "US",
    #[string]$Region = "EU",
    #[string]$Region = "Self-hosted",
    [string]$BaseUrl = "https://vault.bitwarden.com",
    [string]$ApiUrl = $null,
    [string]$IdentityUrl = $null,
    [string]$WebVaultUrl = $null,
    [string]$IconsUrl = $null,
    [string]$NotificationsUrl = $null,
    [string]$EventsUrl = $null,
    [string]$KeyConnectorUrl = $null
)

# Set log file path
$logFile = "$LogFolder\Bitwarden_Install.log"

# Ensure log folder exists if logging is enabled
if ($EnableLogging -eq "Yes" -and !(Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# Function to write logs (respects EnableLogging & Verbosity settings)
function Write-Log {
    param ([string]$message, [int]$level = 0, [switch]$Separator)

    if ($level -le $Verbosity) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "$timestamp - $message"

        if ($EnableLogging -eq "Yes") {
            if ($Separator) { "--------------------------------------------------------------" | Out-File -FilePath $logFile -Append }
            "$logMessage" | Out-File -FilePath $logFile -Append
        } else {
            Write-Host $logMessage
        }
    }
}

Write-Log "Starting Bitwarden upgrade process..." 0 -Separator
Write-Log "Logging enabled: $EnableLogging | Verbosity: $Verbosity" 1
Write-Log "Using Installer: $InstallerPath" 1
Write-Log "Installed Path: $InstalledPath" 1
Write-Log "Data.json Path: $DataJsonPath" 1
Write-Log "Data.json mode: $DataJsonMode" 0
Write-Log "Auto-update setting: $AutoUpdate" 1
Write-Log "Region: $Region" 1
Write-Log "Base URL: $BaseUrl" 1

# Function to get installed Bitwarden version
function Get-BitwardenVersion {
    if (Test-Path $InstalledPath) {
        $version = (Get-Item $InstalledPath).VersionInfo.ProductVersion
        return $version -replace "\.0$", ""  # Remove trailing ".0" if present
    }
    return "Not Installed"
}

# Get the current installed version
$currentVersion = Get-BitwardenVersion
Write-Log "Current installed Bitwarden version: $currentVersion" 0

# Get the version from the installer file
function Get-InstallerVersion {
    if (Test-Path $InstallerPath) {
        $version = (Get-Item $InstallerPath).VersionInfo.ProductVersion
        return $version -replace "\.0$", ""  # Remove trailing ".0" if present
    }
    return "Unknown"
}

$newVersion = Get-InstallerVersion
Write-Log "Installer contains version: $newVersion" 0

# **Check if upgrade is needed**
if ($currentVersion -eq $newVersion) {
    Write-Log "No upgrade needed. Installed version ($currentVersion) matches the installer version ($newVersion)." 0 -Separator
} else {
    Write-Log "Upgrade required: Installing new version $newVersion" 0

    # Stop any running Bitwarden processes before upgrading
    Write-Log "Stopping any running Bitwarden processes..." 1
    Get-Process -Name "Bitwarden" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Log "Bitwarden processes stopped." 1

    # Install or upgrade Bitwarden
    Write-Log "Starting Bitwarden installation/upgrade..." 0
    Start-Process -FilePath $InstallerPath -ArgumentList "/allusers /S" -NoNewWindow -Wait
    Write-Log "Bitwarden installation/upgrade completed." 0
}

# **Replace or update data.json**
if ($DataJsonMode -eq "Replace" -and (Test-Path $SourceJsonPath)) {
    Write-Log "Replacing data.json with a new version..." 0
    Copy-Item -Path $SourceJsonPath -Destination $DataJsonPath -Force
    Write-Log "data.json replaced successfully." 0
} elseif ($DataJsonMode -eq "Update") {
    # Ensure the Bitwarden folder exists before writing data.json
    $bitwardenFolder = [System.IO.Path]::GetDirectoryName($DataJsonPath)
    if (!(Test-Path $bitwardenFolder)) {
        Write-Log "Creating Bitwarden configuration folder: $bitwardenFolder" 0
        New-Item -ItemType Directory -Path $bitwardenFolder -Force | Out-Null
    }

    if (!(Test-Path $DataJsonPath)) {
        Write-Log "Creating a new data.json file..." 0

        # Create new JSON structure with provided parameters
        $NewJson = @{
            "global_environment_environment" = @{
                "region" = $Region
                "urls" = @{
                    "base" = $BaseUrl
                    "api" = $ApiUrl
                    "identity" = $IdentityUrl
                    "webVault" = $WebVaultUrl
                    "icons" = $IconsUrl
                    "notifications" = $NotificationsUrl
                    "events" = $EventsUrl
                    "keyConnector" = $KeyConnectorUrl
                }
            }
        }

        $NewJson | ConvertTo-Json -Depth 100 | Set-Content $DataJsonPath
        Write-Log "data.json created successfully." 0
    } else {
        Write-Log "Updating existing data.json..." 0

        # Read and update JSON
        $JsonData = Get-Content $DataJsonPath -Raw | ConvertFrom-Json
        $JsonData.global_environment_environment = @{
            "region" = $Region
            "urls" = @{
                "base" = $BaseUrl
                "api" = $ApiUrl
                "identity" = $IdentityUrl
                "webVault" = $WebVaultUrl
                "icons" = $IconsUrl
                "notifications" = $NotificationsUrl
                "events" = $EventsUrl
                "keyConnector" = $KeyConnectorUrl
            }
        }

        $JsonData | ConvertTo-Json -Depth 100 | Set-Content $DataJsonPath
        Write-Log "data.json updated successfully." 0
    }
}

# **Disable auto-updates system-wide if AutoUpdate is set to "No"**
if ($AutoUpdate -eq "No") {
    Write-Log "Disabling Bitwarden auto-updates system-wide..." 0
    [System.Environment]::SetEnvironmentVariable("ELECTRON_NO_UPDATER", "1", "Machine")
    Write-Log "Auto-updates disabled system-wide." 0
} else {
    Write-Log "Auto-updates remain enabled." 1
}

Write-Log "Bitwarden upgrade process completed!" 0 -Separator
if ($EnableLogging -eq "Yes") { Write-Host "Installation complete. Check log file at: $logFile" }
