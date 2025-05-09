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
    Import-File "aliases.ps1"
    Import-File "general.ps1"
    Import-File "GitCommands.ps1"
    Import-File "private.ps1"
    Import-File "DockerCommands.ps1"
    Import-File "K8sCommands.ps1"
    Import-File "choco.ps1"
)

foreach ($import in $imports) {
    . $import
    Write-Host "Imported $import" -ForegroundColor Green
}

oh-my-posh init pwsh --config "$Home\Documents\PowerShell\oh-my-posh.json" | Invoke-Expression
"Imported theme"

function ShowHelp {
    $gitContext = [ContextCommands]::new('Git', (GitCommands))
    $dockerContext = [ContextCommands]::new('Docker', (DockerCommands))
    $k8sContext = [ContextCommands]::new('Kubernetes', (K8sCommands))

    $allContexts = @($gitContext, $dockerContext, $k8sContext)

    Show-Help-Template -Contexts $allContexts
}