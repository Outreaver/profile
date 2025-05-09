function KBash {
    kubectl run bash --image=alpine/curl -it --restart=Never --command -- /bin/ash
    kubectl delete po bash
}

function KChangeNs {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    kubectl config set-context --current --namespace=$Name
}

function K8sCommands {
    $commands = @(
        [Command]::new('KBash', 'Runs bash inside cluster with access to cURL'),
        [Command]::new('KChangeNs', 'Change current context namespace', @( [CommandParameter]::new('Name', $true)))
    )

    return $commands;
}