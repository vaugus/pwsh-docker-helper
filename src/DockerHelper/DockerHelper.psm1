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
      [string] $ComputerName
    )

  begin {
    if (![string]::IsNullOrWhitespace($ComputerName)) {
      $env:DOCKER_HOST = "ssh://root@$ComputerName"
    }
  }
  
  process {
    docker build -t "$Tag" -f "$Dockerfile" "$Context"
  }

  end {
    $env:DOCKER_HOST = ''
  }
}

Export-ModuleMember -Function Build-DockerImage