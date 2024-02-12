#!/usr/bin/env pwsh

$global:SERVER_IP_JSONPATH='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

function AssertDockerBuildSuccess {
  [CmdletBinding()]
    param(
      [Parameter(Mandatory)]
      [string] $Tag,

      [Parameter(Mandatory)]
      [System.Object[]] $BuildOutput,

      [Parameter(Mandatory = $false)]
      [string] $ComputerName
    )
  
  begin {
    $LASTEXITCODE | Should -BeExactly 0
    $BuildOutput | Should -Not -Be $null
    if (![string]::IsNullOrWhitespace($ComputerName)) {
      $env:DOCKER_HOST = "ssh://root@$ComputerName" + ":2222"
    }
  }
    
  process {
    docker images
    (docker images | Select-String "$Tag" -Quiet) | Should -BeTrue
  }
  
  end {
    $env:DOCKER_HOST = ''
  }
}

function SetupCustomBuildContext {
  New-Item -Path "./custom/context" -ItemType Directory
  $pwshTar = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-musl-x64.tar.gz"
  Invoke-WebRequest $pwshTar -OutFile "./custom/context/powershell.tar.gz"
}

function TearDownBuildContextAndImages {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [string[]] $ComputerName,

    [Parameter(Mandatory)]
    [string[]] $Tags
  )

  begin {
    if (![string]::IsNullOrWhitespace($ComputerName)) {
      $env:DOCKER_HOST = "ssh://root@$ComputerName" + ":2222"
    }
  }
    
  process {
    foreach ($tag in $Tags) { docker rmi "$tag" }
    Remove-Item "./custom" -Recurse -Force
  }
  
  end {
    $env:DOCKER_HOST = ''
  }
}

function Get-ServerIP {
  return (docker inspect --format=$SERVER_IP_JSONPATH server).ToString()
}

function SetupRemoteServer {
  $identityFilePath = (Get-Location).ToString() + "/test/resources/server/docker_helper"
  ssh-keygen -b 2048 -t rsa -f test/resources/server/docker_helper -q -N ""
  docker run --privileged --name server -p 2222:2222 -d docker:dind

  $serverIP = Get-ServerIP

  ssh-keygen -f ~/.ssh/known_hosts -R "[$serverIP]:2222"
  docker cp test/resources/server/docker_helper.pub server:/root/authorized_keys
  docker cp test/resources/server/ssh_server.sh server:/root/
  docker exec -i server /root/ssh_server.sh

  # this is necessary for github workflow runner to connect to the server
  New-Item ~/.ssh -ItemType Directory -ErrorAction SilentlyContinue
	
  Add-Content -Path ~/.ssh/config -Value "Host $serverIP" 
  Add-Content -Path ~/.ssh/config -Value "    StrictHostKeyChecking no"
  Add-Content -Path ~/.ssh/config -Value "    IdentitiesOnly yes"
  Add-Content -Path ~/.ssh/config -Value "    IdentityFile $identityFilePath"

  ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i test/resources/server/docker_helper -p 2222 root@"$serverIP" "docker ps"
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