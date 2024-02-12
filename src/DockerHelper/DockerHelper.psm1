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

Export-ModuleMember -Function Build-DockerImage
Export-ModuleMember -Function Copy-Prerequisites