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
      $env:DOCKER_HOST = "ssh://root@$ComputerName" + ":$Port"
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
      [string] $Destination
    )
  
}


Export-ModuleMember -Function Build-DockerImage