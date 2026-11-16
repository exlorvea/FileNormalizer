
# FileNormalizer
# Copyright (C) 2026 exlorvea
# SPDX-License-Identifier: GPL-3.0-or-later
# Version 1.2.0
# Normalise les noms de fichiers pour Windows, Linux et macOS.
# Par defaut, aucune modification n'est effectuee.

[CmdletBinding()]
param(
    [string]$Path = ".",
    [switch]$Recurse,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Convert-ToAsciiName {
    param([string]$Text)

    # Transliterations particulieres.
    # Les codes Unicode evitent les problemes d'encodage PS 5.1.
    $map = @{
        ([string][char]0x00E6) = "ae"
        ([string][char]0x0153) = "oe"
        ([string][char]0x00DF) = "ss"
        ([string][char]0x00F8) = "o"
        ([string][char]0x0142) = "l"
        ([string][char]0x0111) = "d"
        ([string][char]0x00F0) = "d"
        ([string][char]0x00FE) = "th"
    }

    $Text = $Text.ToLowerInvariant()

    foreach ($key in $map.Keys) {
        $Text = $Text.Replace(
            [string]$key,
            [string]$map[$key]
        )
    }

    # Supprime les accents par decomposition Unicode.
    $normalized = $Text.Normalize(
        [Text.NormalizationForm]::FormD
    )

    $builder = New-Object System.Text.StringBuilder

    foreach ($char in $normalized.ToCharArray()) {
        $category = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($char)

        if ($category -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($char)
        }
    }

    return $builder.ToString().Normalize(
        [Text.NormalizationForm]::FormC
    )
}

function Get-NormalizedName {
    param([string]$Name)

    $extension = [IO.Path]::GetExtension($Name).ToLowerInvariant()
    $baseName = [IO.Path]::GetFileNameWithoutExtension($Name)

    # Decode les espaces encodes et les signes +.
    $baseName = $baseName -replace '(?i)%20', ' '
    $baseName = $baseName.Replace('+', ' ')

    $baseName = Convert-ToAsciiName $baseName

    # Conserve les tirets simples et les underscores.
    $baseName = $baseName -replace '[^a-z0-9_-]+', '_'

    # Nettoie les repetitions.
    $baseName = $baseName -replace '_+', '_'
    $baseName = $baseName -replace '-{2,}', '-'

    # Supprime les separateurs en debut et fin.
    $baseName = $baseName.Trim([char[]]@('_', '-'))

    if ([string]::IsNullOrWhiteSpace($baseName)) {
        $baseName = "unnamed"
    }

    # Noms reserves sous Windows.
    if ($baseName -match '^(con|prn|aux|nul|com[1-9]|lpt[1-9])$') {
        $baseName = "_" + $baseName
    }

    # Limite conservative de longueur.
    $maxLength = 180 - $extension.Length

    if ($baseName.Length -gt $maxLength) {
        $baseName = $baseName.Substring(0, $maxLength)
        $baseName = $baseName.TrimEnd([char[]]@('_', '-'))
    }

    return $baseName + $extension
}

# Verification du dossier.
$target = (Resolve-Path -LiteralPath $Path).ProviderPath

if (-not (Test-Path -LiteralPath $target -PathType Container)) {
    throw "Le chemin indique n'est pas un dossier."
}

# Recuperation des fichiers.
$files = @(
    Get-ChildItem -LiteralPath $target -File -Recurse:$Recurse |
        Sort-Object FullName
)

# Reserve tous les noms existants pour eviter les collisions.
$reserved = @{}

foreach ($file in $files) {
    $directory = $file.DirectoryName

    if (-not $reserved.ContainsKey($directory)) {
        $reserved[$directory] = @{}
        Get-ChildItem -LiteralPath $directory -File | ForEach-Object {
            $reserved[$directory][$_.Name.ToLowerInvariant()] = $true
        }
    }
}

$changes = New-Object System.Collections.Generic.List[object]

foreach ($file in $files) {
    $directory = $file.DirectoryName
    $newName = Get-NormalizedName $file.Name

    if ($newName -ceq $file.Name) {
        continue
    }

    $extension = [IO.Path]::GetExtension($newName)
    $baseName = [IO.Path]::GetFileNameWithoutExtension($newName)

    $candidate = $newName
    $counter = 1

    # Evite les collisions avec les fichiers existants.
    while (
        $reserved[$directory].ContainsKey($candidate.ToLowerInvariant()) -and
        $candidate -ine $file.Name
    ) {
        $suffix = "_{0:D3}" -f $counter
        $candidate = $baseName + $suffix + $extension
        $counter++
    }

    $reserved[$directory][$candidate.ToLowerInvariant()] = $true

    $changes.Add([PSCustomObject]@{
        OldPath = $file.FullName
        NewPath = Join-Path $directory $candidate
        NewName = $candidate
    })
}

if ($changes.Count -eq 0) {
    Write-Host "Aucun fichier a renommer."
    return
}

# Affiche toujours le plan de renommage.
$changes |
    Select-Object OldPath, NewPath |
    Format-Table -AutoSize -Wrap

Write-Host ("Fichiers a renommer : {0}" -f $changes.Count)

if (-not $Apply) {
    Write-Host "Apercu uniquement. Ajoutez -Apply pour renommer."
    return
}

# Journal de suivi en dehors du dossier traite.
$logPath = Join-Path $env:TEMP (
    "FileNormalizer_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss_fff")
)

$completed = New-Object System.Collections.Generic.List[object]

try {
    foreach ($change in $changes) {
        Rename-Item -LiteralPath $change.OldPath -NewName $change.NewName
        $completed.Add($change)
    }
}
finally {
    if ($completed.Count -gt 0) {
        $completed |
            Select-Object OldPath, NewPath |
            Export-Csv -LiteralPath $logPath -NoTypeInformation -Encoding UTF8

        Write-Host "Journal : $logPath"
    }
}

Write-Host ("Renommages effectues : {0}" -f $completed.Count)
