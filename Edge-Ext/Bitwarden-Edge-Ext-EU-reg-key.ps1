# --- Base functions ---
# Function to write log
function Write-Log {
    param (
        [string]$message
    )

    try {
        # Ensure the directory exists for logging
        $logDirectory = Split-Path -Path $logFile -Parent
        if (!(Test-Path -Path $logDirectory)) {
            New-Item -Path $logDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $logFile -Value "$timestamp - $message" -ErrorAction Stop 

        # Keep only the last 500 lines
        $maxLines = 500
        $lines = Get-Content -Path $logFile -ErrorAction Stop 
        if ($lines.Count -gt $maxLines) {
            $lines | Select-Object -Last $maxLines | Set-Content -Path $logFile -ErrorAction Stop 
        }
    }
    catch {
        # Write a message to the console if logging fails
        Write-Output "Error writing to log file: $($_.Exception.Message)"
        exit 1
    }
}
# Function to create or update registry key
function Set-RegistryKey {
    param (
        [string]$path,
        [string]$name,
        [string]$type,
        [string]$data
    )

    try {

        # Check if the registry path exists
        if (-not (Test-Path -Path $path)) {
            Write-Log "Registry path $path does not exist. Creating it."
            New-Item -Path $path -Force -ErrorAction Stop | Out-Null
            Write-Log "Created registry path $path"
        }

        # Check if the property (value name) exists
        $currentValue = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue

        if ($currentValue) {
            # If the key exists, update it if necessary
            if ($currentValue.$name -ne $data) {
                Set-ItemProperty -Path $path -Name $name -Value $data -ErrorAction Stop
                Write-Log "Updated $name to $data at $path"
            }
            else {
                Write-Log "$name already set to $data at $path"
            }
        }
        else {
            # If the key does not exist, create it
            New-ItemProperty -Path $path -Name $name -PropertyType $type -Value $data -Force -ErrorAction Stop
            Write-Log "Created $name with value $data at $path"
        }
    }
    catch {
        Write-Log "Error setting $name at $path\: $($_.Exception.Message)"
        exit 1
    }
}


# --- Specific settings for this script ---

# Define the log file location
$logFile = "C:\ProgramData\IntuneScripts\platformcriptChangeLog.txt"

# Define registry values to set 
$registrySettings = @(
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "base"; Type = "STRING"; Data = "https://vault.bitwarden.eu" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "notifications"; Type = "STRING"; Data = "https://notifications.bitwarden.eu" }
    
)

# Set keys
foreach ($setting in $registrySettings) {
    $registryPath = $setting.Path
    $valueName = $setting.Name
    $valueType = $setting.Type
    $expectedValue = $setting.Data
    Set-RegistryKey -path $registryPath -name $valueName -type $valueType -data $expectedValue
}

exit 0
