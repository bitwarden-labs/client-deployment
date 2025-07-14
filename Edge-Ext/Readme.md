# Bitwarden Powershell Script to set .EU cloud or Self-Hosted URLs in the Windows registry

This PowerShell script should be excuted in system context and sets the vault.bitwarden.EU target for the Bitwarden MS Edge Extension.

**The script is based on an example provided by *https://gist.github.com/eddiez9/061deac19e3e9f7d31cf48bc372b6533* by Eddie Zhang**

Bu default the Script logs to a text file under 'C:\ProgramData'

The script can be executed locally if you have Windows Administrative privileges, or remotely using a tool like Intune Platform Scripts or Remediation Scripts.

The script should be executed prior to deploying the Bitwarden extension to ensure that the correct URL is set in the registry.

🚀 Features
Logging, Set or Overwrite existing values.

📌 Usage Examples
Before running the script, you may need to set the PowerShell execution policy to allow the script to run. Use the following command to bypass the execution policy for the current session:

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

▶ To execute the script

.\Bitwarden-Edge-Ext-EU-reg-key.ps1

If you wish to adjust for a Self-Hosted installation, you can follow the documentation from Bitwarden: *https://bitwarden.com/help/configure-clients-selfhost/#tab-windows-55MXwgIamulyigoLoAbLMo*
and update the script accordingly changing the Data for each registry key:

## Vault.bitwarden.eu example: 
$registrySettings = @(
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "base"; Type = "STRING"; Data = "https://vault.bitwarden.eu" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "notifications"; Type = "STRING"; Data = "https://notifications.bitwarden.eu" }
    
)
##
## Self hosted example where "bitwarden.selfhostexample.com" represents a single self hosted instance of Bitwarden Password Manager):

Define registry values to set 
$registrySettings = @(
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "base"; Type = "STRING"; Data = "https://bitwarden.selfhostexample.com" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "notifications"; Type = "STRING"; Data = "https://bitwarden.selfhostexample.com"},
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "webVault"; Type = "STRING"; Data = "https://bitwarden.selfhostexample.com" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "api"; Type = "STRING"; Data = "https://bitwarden.selfhostexample.com"},
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "identity"; Type = "STRING"; Data = "https://bitwarden.selfhostexample.com" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "icons"; Type = "STRING"; Data = "https://bitwarden.selfhostexample.com"},
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\jbkfoedolllekgbhcbcoahefnbanhhlh\policy\environment"; Name = "events"; Type = "STRING"; Data = "https://bitwarden.selfhostexample.com" }
)
##

📜 License
This script is provided as is, with no warranty. Modify it to fit your needs.
