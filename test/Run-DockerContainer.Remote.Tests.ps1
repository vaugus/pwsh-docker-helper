Import-Module (Join-Path (Get-Location) "test/TestUtils")

$DockerHelperPath = Join-Path ($MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent) "src/DockerHelper"
Import-Module $DockerHelperPath


InModuleScope DockerHelper {

  Describe -Name "Run-DockerContainer" -Tags @("remote") {

    Context "Run docker container in a remote host." {

      It "runs a simple container without docker parameters" {
        $computerName = Get-ServerIP

        $hello = (Run-DockerContainer -ImageName "hello-world:latest" `
          -ComputerName "$computerName" -Port 2222) -join "`n"

        $hello | Should -Not -BeNullOrEmpty
      }

      It "runs a simple container with docker parameters" {
        $computerName = Get-ServerIP

        $alpine = (Run-DockerContainer -ImageName "alpine:latest" `
          -ComputerName "$computerName" -Port 2222 `
          -DockerParams "-d", "--name=alpine" `
          -Command "/bin/sh")  -join "`n"

        $alpine | Should -BeLikeExactly "/alpine"
      }
    }
  }
}
