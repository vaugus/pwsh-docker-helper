function Build-DockerImage {
  [CmdletBinding()]
    param(
      [Parameter(Mandatory)]
      [string] $Dockerfile,

      [Parameter(Mandatory)]
      [string] $Tag,

      [Parameter(Mandatory)]
      [string] $Context,

      [Parameter(Mandatory=$false)]
      [string] $ComputerName,

      [Parameter(Mandatory=$false)]
      [int] $Port = 22
    )

  begin {
    if (![string]::IsNullOrWhitespace($ComputerName)) {
      $env:DOCKER_HOST = "ssh://root@$ComputerName" + ":" + $Port.ToString()
    }
  }
  
  process {
    docker build -t "$Tag" -f "$Dockerfile" "$Context"
  }

  end {
    $env:DOCKER_HOST = ''
  }
}

function Copy-Prerequisites {
  [CmdletBinding()]
    param(
      [Parameter(Mandatory)]
      [string] $ComputerName,

      [Parameter(Mandatory)]
      [string[]] $Path,

      [Parameter(Mandatory)]
      [string] $Destination,
      
      [Parameter(Mandatory = $false)]
      [System.Collections.Hashtable] $SessionProperties
    )

  begin {
    $session = New-PSSession -Port ([int] $SessionProperties['Port']) `
      -HostName "$ComputerName" `
      -UserName $SessionProperties['UserName'] `
      -KeyFilePath $SessionProperties['KeyFilePath']
  }

  process {
    Copy-Item "$Path" -Destination "$Destination" -ToSession $session
  }

  end {
    Remove-PSSession $session
  }
}

function Run-DockerContainer {
  [CmdletBinding()]
    param(
      [Parameter(Mandatory)]
      [string] $ImageName,

      [Parameter(Mandatory = $false)]
      [string] $ComputerName = "localhost",

      [Parameter(Mandatory = $false)]
      [string[]] $DockerParams,

      [Parameter(Mandatory = $false)]
      [int] $Port = 22,

      [Parameter(Mandatory = $false)]
      [string] $Command = 'standard command'
    )

  begin {
    if (![string]::IsNullOrWhitespace($ComputerName) -and !$ComputerName.Equals("localhost")) {
      $env:DOCKER_HOST = "ssh://root@$ComputerName" + ":" + $Port.ToString()
    }
  }
  
  process {
    Write-Host "Will run $Command in a container with $ImageName image."
    if (!$Command.Equals('standard command')) {
      $containerId = (docker run -d $DockerParams $ImageName $Command).ToString()
    } else {
      $containerId = (docker run -d $DockerParams $ImageName).ToString()
    }

    return (docker inspect --format='{{.Name}}' "$containerId").ToString()
  }

  end {
    $env:DOCKER_HOST = ''
  }
}

Export-ModuleMember -Function Build-DockerImage
Export-ModuleMember -Function Copy-Prerequisites
Export-ModuleMember -Function Run-DockerContainer
