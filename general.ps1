class CommandParameter {
    [string]$Name
    [bool]$Required

    CommandParameter([string]$name, [bool]$required) {
        $this.Name = $name
        $this.Required = $required
    }
}

class Command {
    [string]$Name
    [string]$Description
    [CommandParameter[]]$Parameters

    Command([string]$name, [string]$description, [CommandParameter[]]$parameters) {
        $this.Name = $name
        $this.Description = $description
        $this.Parameters = $parameters
    }

    Command([string]$name, [string]$description) {
        $this.Name = $name
        $this.Description = $description
        $this.Parameters = @()
    }
}

class ContextCommands {
    [string]$Name
    [Command[]]$Commands

    ContextCommands([string]$Name, [Command[]]$Commands) {
        $this.Name = $Name
        $this.Commands = $Commands
    }
}

function Show-Help-Template {
    param (
        [Parameter(Mandatory = $true)]
        [ContextCommands[]]$Contexts
    )

    $allCommands = $Contexts | ForEach-Object { $_.Commands }
    $maxNameLength = ($allCommands | Measure-Object -Property Name -Maximum).Maximum.Length

    foreach ($context in $Contexts) {
        Write-Host "`n$($context.Name):" -ForegroundColor DarkYellow
        foreach ($cmd in $context.Commands) {
            $paddedName = $cmd.Name.PadRight($maxNameLength + 20)
            Write-Host "  $paddedName" -NoNewline -ForegroundColor Yellow
            Write-Host "$($cmd.Description)"

            foreach ($param in $cmd.Parameters) {
                $req = if ($param.Required) { 'required' } else { 'optional' }
                Write-Host "    - $($param.Name)" -NoNewline -ForegroundColor Cyan
                Write-Host " [$req]"
            }
        }
    }
}

function cdsr { Set-Location $Home/source/repos }