function Build-DockerImage {
  [CmdletBinding()]
    param(
      [Parameter(Mandatory)]
      [string] $Dockerfile,

      [Parameter(Mandatory)]
      [string] $Tag,

      [Parameter(Mandatory)]
      [string] $Context
    )

  docker build -t "$Tag" -f "$Dockerfile" "$Context"
}

Export-ModuleMember -Function Build-DockerImage