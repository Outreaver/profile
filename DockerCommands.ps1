function DRemoveNoneImages {
    docker images --filter "dangling=true" -q | ForEach-Object { docker rmi $_ }
}

function DockerCommands {
    $commands = @(
        [Command]::new('DRemoveNoneImages', 'Removes dangling (<none>) images.')
    )

    return $commands;
}