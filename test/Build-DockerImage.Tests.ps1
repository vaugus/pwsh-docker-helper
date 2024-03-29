Import-Module (Join-Path (Get-Location) "test/TestUtils")

$DockerHelperPath = Join-Path ($MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent) "src/DockerHelper"
Import-Module $DockerHelperPath


InModuleScope DockerHelper {

  Describe -Name "Build-DockerImage" -Tags @("local") {

    Context "Build image in the directory where Dockerfile resides." {

      BeforeAll {
        $initialPath = Get-Location
        Set-Location -Path (Join-Path -Path $initialPath -ChildPath "test/resources/pwsh-alpine/")
        SetupCustomBuildContext
      }

      It "builds image in the Dockerfile directory without context settings" {
        $output = Build-DockerImage -Dockerfile "Dockerfile.no-context" `
          -Tag "pwsh-alpine:latest" `
          -Context . 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine" -BuildOutput $output
      }

      It "builds image in the Dockerfile directory with context directory" {
        $output = Build-DockerImage -Dockerfile "Dockerfile.context" `
          -Tag "pwsh-alpine-context:latest" `
          -Context "./custom/context/" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-context" -BuildOutput $output
      }

      AfterAll {
        TearDownBuildContextAndImages -Tags 'pwsh-alpine:latest', 'pwsh-alpine-context:latest'
        Set-Location -Path $initialPath
      }
    }

    Context "Build image with custom Dockerfile directory." {

      BeforeAll {
        SetupCustomBuildContext
      }

      It "builds image without context settings" {
        $output = Build-DockerImage -Dockerfile "./test/resources/pwsh-alpine/Dockerfile.no-context" `
          -Tag "pwsh-alpine:latest" `
          -Context . 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine" -BuildOutput $output
      }

      It "builds image with context directory" {
        $output = Build-DockerImage -Dockerfile "./test/resources/pwsh-alpine/Dockerfile.context" `
          -Tag "pwsh-alpine-context:latest" `
          -Context "./custom/context/" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-context" -BuildOutput $output
      }

      AfterAll {
        TearDownBuildContextAndImages -Tags 'pwsh-alpine:latest', 'pwsh-alpine-context:latest'
      }
    }
  }
}
