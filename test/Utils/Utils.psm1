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

Export-ModuleMember -Function AssertDockerBuildSuccess
Export-ModuleMember -Function SetupCustomBuildContext
Export-ModuleMember -Function TearDownBuildContextAndImages