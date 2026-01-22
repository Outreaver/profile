function GNewBranch {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    git checkout -b $Name
}   

function GCommit {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    git commit -m $Message
}

function GCommitAll {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    git add -A
    GCommit $Message
}

function GRenameLast {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    git commit --amend -m "$Message"
}

function GUpdateLast {
    git add -A
    git commit --amend --no-edit
}

function GUndoLast {
    git reset HEAD~1
}

function GStashAll {
    git stash --include-untracked
}

function GStashAndKeep {
    git stash --keep-index --include-untracked
}

function GGetStash {
    param (
        [Parameter(Mandatory = $false)]
        [int]$Index
    )
    $i = $Index ? $Index : 0;

    git stash apply $i --index
}

function GReset {
    git reset --hard
    git clean -df
}

function GAddTag {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TagName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    git tag -a $TagName -m $Message
    git push origin --tags
}

function GLogOne {
    param (
        [int]$Size = 20
    )

    $format = "--pretty=format:%Cred%h%Creset - %<($Size,trunc)%s %Cgreen(%cr) %C(bold blue)<%an>%Creset"

    git log --graph $format --abbrev-commit
}

function GRemoveOldBranches {
    # Remove local git branches older than 3 days that don't exist on origin
    param(
        [int]$DaysOld = 3,
        [string]$RemoteName = "origin",
        [switch]$WhatIf
    )

    # Get the current date
    $cutoffDate = (Get-Date).AddDays(-$DaysOld)

    # Fetch latest remote info without pulling
    Write-Host "Fetching latest remote info..." -ForegroundColor Cyan
    git fetch $RemoteName --prune

    # Get all local branches with their last commit date
    Write-Host "Checking local branches..." -ForegroundColor Cyan
    $branchesToDelete = @()

    # Get all local branches except the current one
    $branches = git branch --format='%(refname:short)' | Where-Object { $_ -ne "" }

    foreach ($branch in $branches) {
        # Get the last commit date for this branch
        $lastCommitDate = git log -1 --format=%ai "$branch" | ForEach-Object { [DateTime]$_ }
        
        # Check if branch exists on remote (exit code 0 if exists, 1 if not)
        git show-ref --quiet refs/remotes/$RemoteName/$branch
        $existsOnRemote = $LASTEXITCODE -eq 0
        
        # Delete if older than cutoff AND does not exist on remote
        if ($lastCommitDate -lt $cutoffDate -and -not $existsOnRemote) {
            Write-Host "Branch '$branch' last commit: $lastCommitDate (older than $DaysOld days, not on $RemoteName)" -ForegroundColor Yellow
            $branchesToDelete += $branch
        }
    }

    if ($branchesToDelete.Count -eq 0) {
        Write-Host "No branches to delete." -ForegroundColor Green
        return;
    }

    Write-Host "`nBranches to delete:`n" -ForegroundColor Yellow
    $branchesToDelete | ForEach-Object { Write-Host "  - $_" }

    if ($WhatIf) {
        Write-Host "`n[WhatIf] No branches were deleted." -ForegroundColor Cyan
        return;
    }

    # Confirm deletion
    $response = Read-Host "`nDelete these branches? (y/yes/no)"
    if ($response.ToLower() -notin @("y", "yes")) {
        Write-Host "Cancelled." -ForegroundColor Cyan
        return;
    }

    # Delete branches
    Write-Host "Deleting branches..." -ForegroundColor Cyan
    $deletedCount = 0
    foreach ($branch in $branchesToDelete) {
        git branch -D $branch
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Deleted: $branch" -ForegroundColor Green
            $deletedCount++
        } else {
            Write-Host "✗ Failed to delete: $branch" -ForegroundColor Red
        }
    }

    Write-Host "`nDone! Deleted $deletedCount out of $($branchesToDelete.Count) branches." -ForegroundColor Green
}

function GitCommands {
    $commands = @(
        [Command]::new('GNewBranch', 'Creates new branch and checks out', @( [CommandParameter]::new('Name', $true))),
        [Command]::new('GCommit', 'Commits changes with message (without add)', @( [CommandParameter]::new('Message', $true))),
        [Command]::new('GCommitAll', 'Adds current changes to working tree and commits', @( [CommandParameter]::new('Message', $true))),
        [Command]::new('GRenameLast', 'Renames last commit without any changes', @( [CommandParameter]::new('Message', $true))),
        [Command]::new('GUpdateLast', 'Adds current changes and updates last commit (without message change)', @()),
        [Command]::new('GUndoLast', 'Undo last commit and brings back changes to working directory', @()),
        [Command]::new('GStashAll', 'Stashes all changes (and leaves empty working directory)', @()),
        [Command]::new('GStashAndKeep', 'Stashes all changes and keeps staging', @()),
        [Command]::new('GGetStash', 'Get stash', @( [CommandParameter]::new('Index', $false))),
        [Command]::new('GReset', 'Cleanses working directory', @()),
        [Command]::new('GAddTag', 'Adds tag to commit', @( [CommandParameter]::new('TagName', $true), [CommandParameter]::new('Message', $true))),
        [Command]::new('GLogOne', 'Prints nicely git log with one liners', @( [CommandParameter]::new('Size', $false) )),
        [Command]::new('GRemoveOldBranches', 'Removes local branches older than N days that dont exist on remote', @( [CommandParameter]::new('DaysOld', $false), [CommandParameter]::new('RemoteName', $false), [CommandParameter]::new('WhatIf', $false) ))
    )

    return $commands;
}