function DRemoveNoneImages {
    docker images --filter "dangling=true" -q | ForEach-Object { docker rmi $_ }
}

function DBash {
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Container
    )

    if ([string]::IsNullOrWhiteSpace($Container)) {
        docker run -it --rm busybox
    }
    else {
        docker exec -it $Container /bin/sh
    }
}

function DockerCommands {
    $commands = @(
        [Command]::new('DRemoveNoneImages', 'Removes dangling (<none>) images.'),
        [Command]::new('DBash', 'Runs bash inside container', @( [CommandParameter]::new('Container', $false)))
    )

    return $commands;
}