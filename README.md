# FileNormalizer

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-GPLv3-blue)
![Version](https://img.shields.io/badge/Version-1.2.0-green)
![Dependencies](https://img.shields.io/badge/Dependencies-None-brightgreen)

**FileNormalizer** is a lightweight PowerShell script designed to normalize filenames for better compatibility across Windows, Linux, macOS, and web environments.

It requires no external dependencies and supports Windows PowerShell 5.1 and PowerShell 7.

## Features

- Removes accents and transliterates common special characters.
- Converts filenames to lowercase `snake_case`.
- Replaces spaces, `%20`, and `+` with underscores (`_`).
- Preserves single hyphens (`-`).
- Removes unsupported special characters.
- Normalizes repeated separators.
- Prevents filename collisions using numerical suffixes (`_001`, `_002`, etc.).
- Handles reserved Windows filenames.
- Provides a preview before applying changes.
- Supports recursive file processing.
- Generates a CSV log of completed renaming operations.

## Examples

| Original filename | Normalized filename |
|---|---|
| `My Super File.JPG` | `my_super_file.jpg` |
| `P13-01.PNG` | `p13-01.png` |
| `Holiday%20Photos+2026.jpg` | `holiday_photos_2026.jpg` |
| `Été 2026.pdf` | `ete_2026.pdf` |
| `My---File.png` | `my-file.png` |
| `Final Report (2).PDF` | `final_report_2.pdf` |
| `CON.txt` | `_con.txt` |

## Installation

1. Download `FileNormalizer.ps1` from this repository.
2. Save the script to a directory of your choice.
3. Open PowerShell in that directory.

No additional software or modules are required.

If PowerShell script execution is restricted, you can temporarily allow scripts in the current session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This change only affects the current PowerShell session. Review the script before running it.

## Usage

### Preview changes

```powershell
.\FileNormalizer.ps1 -Path "C:\MyFiles"
```

Displays the proposed changes without modifying any files.

### Apply changes

```powershell
.\FileNormalizer.ps1 -Path "C:\MyFiles" -Apply
```

### Process subdirectories

```powershell
.\FileNormalizer.ps1 -Path "C:\MyFiles" -Recurse -Apply
```

The `-Recurse` parameter processes files inside subdirectories but does not rename the directories themselves.

## Parameters

| Parameter | Description |
|---|---|
| `-Path` | Target directory. Defaults to the current directory. |
| `-Recurse` | Includes files in subdirectories. |
| `-Apply` | Applies the changes. Without it, only a preview is displayed. |

## Safety

FileNormalizer does not intentionally delete files or modify their contents.

Renaming operations are only performed when the `-Apply` parameter is specified.

Filename collisions are handled by adding numerical suffixes. A CSV log containing the original and new file paths is generated in the Windows temporary directory.

**Always test the script on a copy of your files before processing important data.**

## Limitations

- Directory names are not modified.
- File extensions are converted to lowercase without changing the actual file format.
- Full transliteration of non-Latin alphabets is not supported.
- CSV logs do not provide automatic rollback functionality.
- Some edge cases involving filename collisions or path lengths may require manual intervention.

## Compatibility

- Windows 10 / 11
- Windows PowerShell 5.1
- PowerShell 7

The resulting filenames are designed for broad compatibility with Linux, macOS, NAS devices, and web servers.

## License

This project is licensed under the **GNU General Public License v3.0 or later (GPL-3.0-or-later)**.

See the [LICENSE](LICENSE) file for details.