# Bitwarden Upgrade Script

This PowerShell script upgrades Bitwarden **only if a different version is available**.  
It logs the old and new versions and updates the configuration (`data.json`).

---

## 🚀 Features
- **Automatic version check** – Upgrades only if a different version is available.
- **Customizable logging** – Enable/disable logs and set verbosity level.
- **Configurable `data.json` handling**:
  - **Update** existing values.
  - **Replace** with a provided file.
  - **Skip** changes entirely.
- **Auto-update control** – Disable Bitwarden's auto-updates system-wide.

---

## 📌 Usage Examples

### ▶ **Run with default settings**
_Defaults to minimal logs, updates `data.json`, and disables auto-updates._
```powershell
.\BitwardenUpgrade.ps1
```

### ▶ **Enable verbose logging**
_Includes detailed logs in the console and log file._
```powershell
.\BitwardenUpgrade.ps1 -Verbosity 1
```

### ▶ **Disable logging to file (console-only output)**
```powershell
.\BitwardenUpgrade.ps1 -EnableLogging No
```

### ▶ **Upgrade Bitwarden but do not modify `data.json`**
```powershell
.\BitwardenUpgrade.ps1 -DataJsonMode None
```

### ▶ **Replace `data.json` with a provided file**
```powershell
.\BitwardenUpgrade.ps1 -DataJsonMode Replace -SourceJsonPath "C:\Users\keith\Downloads\new-data.json"
```

### ▶ **Manually specify the Bitwarden install path**
```powershell
.\BitwardenUpgrade.ps1 -InstalledPath "D:\Bitwarden\Bitwarden.exe"
```

### ▶ **Set custom `data.json` values**
```powershell
.\BitwardenUpgrade.ps1 -DataJsonMode Update -Region "Europe" -BaseUrl "https://vault.example.com"
```

---

## ⚙️ Parameters

| Parameter         | Default Value                                      | Description                                  |
|------------------|--------------------------------------------------|----------------------------------------------|
| `-LogFolder`     | `%USERPROFILE%\Downloads`                        | Path to save log files.                      |
| `-InstallerPath` | `%USERPROFILE%\Downloads\Bitwarden-Installer.exe` | Path to the Bitwarden installer.             |
| `-InstalledPath` | `C:\Program Files\Bitwarden\Bitwarden.exe`        | Path to the installed Bitwarden executable.  |
| `-DataJsonPath`  | `%APPDATA%\Bitwarden\data.json`                   | Path to `data.json`.                         |
| `-SourceJsonPath`| `%USERPROFILE%\Downloads\data.json`               | File to use when replacing `data.json`.      |
| `-DataJsonMode`  | `Update`                                          | Options: `Update`, `Replace`, `None`.       |
| `-AutoUpdate`    | `No`                                              | Set to `Yes` to allow auto-updates.         |
| `-EnableLogging` | `Yes`                                             | Disable with `No` to log only to console.   |
| `-Verbosity`     | `0`                                               | Set to `1` for detailed logs.               |
| `-Region`        | `"Self-hosted"`                                   | Set custom region.                          |
| `-BaseUrl`       | `"https://vault.example.com"`                    | Set custom Bitwarden server URL.            |

---

## 📝 Notes
- If Bitwarden is **not installed**, the script will **create the folder and `data.json`** when `-DataJsonMode Update` is set.
- The **Replace mode** fully overwrites `data.json` with a provided file.
- Auto-updates are **disabled system-wide** unless explicitly enabled.

---

## 📜 License
This script is provided **as is**, with no warranty. Modify it to fit your needs.
