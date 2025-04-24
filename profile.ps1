oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/quick-term.omp.json' | Invoke-Expression

function Make-Link ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target
}