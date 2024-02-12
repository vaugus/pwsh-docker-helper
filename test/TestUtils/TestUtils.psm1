#!/usr/bin/env pwsh

$global:SERVER_IP_JSONPATH='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

function AssertDockerBuildSuccess {
  [CmdletBinding()]
    param(
      [Parameter(Mandatory)]
      [string] $Tag,

      [Parameter(Mandatory)]
      [System.Object[]] $BuildOutput
    )

  $LASTEXITCODE | Should -BeExactly 0
  $BuildOutput | Should -Not -Be $null
  (docker images | Select-String "$Tag" -Quiet) | Should -BeTrue
}

function SetupCustomBuildContext {
  New-Item -Path "./custom/context" -ItemType Directory
  $pwshTar = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-musl-x64.tar.gz"
  Invoke-WebRequest $pwshTar -OutFile "./custom/context/powershell.tar.gz"
}

function TearDownBuildContextAndImages {
  docker rmi pwsh-alpine:latest pwsh-alpine-context:latest
  Remove-Item "./custom" -Recurse -Force
}

function Get-ServerIP {
  return (docker inspect --format=$SERVER_IP_JSONPATH server).ToString()
}

function SetupRemoteServer {
  ssh-keygen -b 2048 -t rsa -f test/resources/server/docker_helper -q -N ""
  docker run --privileged --name server -p 22:22 -d docker:dind

  $serverIP = Get-ServerIP

  ssh-keygen -f ~/.ssh/known_hosts -R "$serverIP"
  docker cp test/resources/server/docker_helper.pub server:/root/authorized_keys
  docker cp test/resources/server/ssh_server.sh server:/root/
  docker exec -i server /root/ssh_server.sh

  ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i test/resources/server/docker_helper root@"$serverIP" "docker ps"
}

function TearDownRemoteServer {
  docker kill server 2>&1 > /dev/null
  docker container rm server 2>&1 > /dev/null
  docker rmi server:latest 2>&1 > /dev/null
  Remove-Item test/resources/server/docker_helper*
}

Export-ModuleMember -Function AssertDockerBuildSuccess
Export-ModuleMember -Function Get-ServerIP
Export-ModuleMember -Function SetupRemoteServer
Export-ModuleMember -Function SetupCustomBuildContext
Export-ModuleMember -Function TearDownBuildContextAndImages
Export-ModuleMember -Function TearDownRemoteServer