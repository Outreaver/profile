function KCurl {
    kubectl run bash --image=alpine/curl -it --restart=Never --command -- /bin/ash
    kubectl delete po bash
}

function KBash {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Pod,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Namespace
    )
    kubectl exec -n $Namespace -it $Pod -- /bin/sh
}

function KChangeNs {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    kubectl config set-context --current --namespace=$Name
}

function KNginxChangePort {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull]
        [int]$Port
    )

    $patch = "{
        `"spec`": {
          `"ports`": [
            {`"port`": 80, `"nodePort`": $port, `"protocol`": `"TCP`", `"targetPort`": 80}
          ],
          `"type`": `"NodePort`"
        }
      }"
    
    kubectl patch service ingress-nginx-controller -n ingress-nginx -p $patch
}

function K8sCommands {
    $commands = @(
        [Command]::new('KCurl', 'Runs bash inside cluster with access to cURL (based on Apline image)'),
        [Command]::new('KBash', 'Runs bash inside pod', @( [CommandParameter]::new('Pod', $true), [CommandParameter]::new('Namespace', $true))),
        [Command]::new('KChangeNs', 'Change current context namespace', @( [CommandParameter]::new('Name', $true))),
        [Command]::new('KNginxChangePort', 'Changes nginx ingress controller to type NodeType it''s port', @( [CommandParameter]::new('Port', $true)))
    )

    return $commands;
}