function GitNewBranch {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    git checkout -b $Name
}   

function GitCommit {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    git commit -m $Message
}

function GitCommitAll {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    git add -A
    GitCommit $Message
}

function GitRenameLast {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    git commit --amend -m "$Message"
}

function GitUpdateLast {
    git add -A
    git commit --amend --no-edit
}

function GitUndoLast {
    git reset HEAD~1
}

function GitAddTag {
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

function GitLogOne {
    param (
        [int]$Size = 20
    )

    $format = "--pretty=format:%Cred%h%Creset - %<($Size,trunc)%s %Cgreen(%cr) %C(bold blue)<%an>%Creset"

    git log --graph $format --abbrev-commit
}