Import-Module (Join-Path (Get-Location) "test/TestUtils")

$DockerHelperPath = Join-Path ($MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent) "src/DockerHelper"
Import-Module $DockerHelperPath


InModuleScope DockerHelper {

  Describe -Name "Run-DockerContainer" -Tags @("local") {

    Context "Run docker container in local host." {

      It "runs a simple container without docker parameters" {
        $hello = (Run-DockerContainer -ImageName "hello-world:latest")
        $hello | Should -Not -BeNullOrEmpty

        docker kill "$hello" 2>&1 > /dev/null
        docker container rm "$hello" 2>&1 > /dev/null
      }

      It "runs a simple container with docker parameters" {
        $alpine = (Run-DockerContainer -ImageName "alpine:latest" `
          -DockerParams "-d", "--name=alpine" `
          -Command "/bin/sh")

        $alpine | Should -BeLikeExactly "/alpine"

        docker kill "$alpine" 2>&1 > /dev/null
        docker container rm "$alpine" 2>&1 > /dev/null
      }
    }
  }
}
