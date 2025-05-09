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
        [Command]::new('GLogOne', 'Prints nicely git log with one liners', @( [CommandParameter]::new('Size', $false) ))
    )

    return $commands;
}