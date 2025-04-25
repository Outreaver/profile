function GetProfileTarget {
    $profileFile = Get-Item $PROFILE
    $targetPath = if ($profileFile.LinkType -eq 'SymbolicLink') { $profileFile.Target } else { $PROFILE }
    return $targetPath;
}

function Import-File {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$fileName
    )
    $profileTarget = GetProfileTarget
    $profileParent = Split-Path $PROFILE -Parent
    $profileTargetParent = Split-Path $profileTarget -Parent

    $fromProfileFolder = Join-Path -Path $profileParent -ChildPath $fileName
    $fromTargetFolder = Join-Path -Path $profileTargetParent -ChildPath $fileName
    $file = Get-Item $fromProfileFolder -ErrorAction 'silentlycontinue' || Get-Item $fromTargetFolder -ErrorAction 'silentlycontinue' || $false
    if (!$file) {
        Write-Host "File $fileName does not exist, skipping import" -ForegroundColor Yellow
        return
    }

    return $file.FullName;
}

$imports = @(
    Import-File "GitCommands.ps1"
    Import-File "private.ps1"
)

foreach ($import in $imports) {
    . $import
    Write-Host "Imported $import" -ForegroundColor Green
}

oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/quick-term.omp.json' | Invoke-Expression
"Imported theme"

function CD-SR { Set-Location $Home/source/repos }

Set-Alias openssl "C:\Program Files\Git\usr\bin\openssl.exe"