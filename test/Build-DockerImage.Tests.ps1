Import-Module (Join-Path (Get-Location) "test/Utils")

$DockerHelperPath = Join-Path ($MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent) "src/DockerHelper"
Import-Module $DockerHelperPath


InModuleScope DockerHelper {

  Describe "Build-DockerImage" {

    Context "[SUCCESS] Build image on localhost in the directory where Dockerfile resides." {

      BeforeAll {
        $initialPath = Get-Location
        Set-Location -Path (Join-Path -Path $initialPath -ChildPath "test/resources/pwsh-alpine/")
        SetupCustomBuildContext
      }

      It "builds image in localhost in the Dockerfile directory without context settings" {
        $output = Build-DockerImage -Dockerfile "Dockerfile.no-context" `
          -Tag "pwsh-alpine:latest" `
          -Context . 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine" -BuildOutput $output
      }

      It "builds image in localhost in the Dockerfile directory with context directory" {
        $output = Build-DockerImage -Dockerfile "Dockerfile.context" `
          -Tag "pwsh-alpine-context:latest" `
          -Context "./custom/context/" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-context" -BuildOutput $output
      }

      AfterAll {
        TearDownBuildContextAndImages
        Set-Location -Path $initialPath
      }
    }

    Context "[SUCCESS] Build image on localhost with custom Dockerfile directory." {

      BeforeAll {
        SetupCustomBuildContext
      }

      It "builds image in localhost without context settings" {
        $output = Build-DockerImage -Dockerfile "./test/resources/pwsh-alpine/Dockerfile.no-context" `
          -Tag "pwsh-alpine:latest" `
          -Context . 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine" -BuildOutput $output
      }

      It "builds image in localhost with context directory" {
        $output = Build-DockerImage -Dockerfile "./test/resources/pwsh-alpine/Dockerfile.context" `
          -Tag "pwsh-alpine-context:latest" `
          -Context "./custom/context/" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-context" -BuildOutput $output
      }

      AfterAll {
        TearDownBuildContextAndImages
      }
    }
  }
}
