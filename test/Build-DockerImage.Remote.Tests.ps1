Import-Module (Join-Path (Get-Location) "test/TestUtils")

$DockerHelperPath = Join-Path ($MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent) "src/DockerHelper"
Import-Module $DockerHelperPath

InModuleScope DockerHelper {

  Describe "Build-DockerImage" {

    Context "[SUCCESS] Build image on remote host." {

      BeforeAll {
        $initialPath = Get-Location
        Set-Location -Path (Join-Path -Path $initialPath -ChildPath "test/resources/pwsh-alpine/")
        SetupCustomBuildContext
      }

      It "builds image in the Dockerfile directory without context settings" {
        $computerName = Get-ServerIP
        $output = Build-DockerImage -Dockerfile "Dockerfile.no-context" `
          -Tag "pwsh-alpine-remote:latest" `
          -Context . `
          -ComputerName "$computerName" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-remote" -BuildOutput $output -ComputerName "$computerName"
      }

      It "builds image in the Dockerfile directory with context directory" {
        $computerName = Get-ServerIP
        $output = Build-DockerImage -Dockerfile "Dockerfile.no-context" `
          -Tag "pwsh-alpine-context-remote:latest" `
          -Context "./custom/context/" `
          -ComputerName "$computerName" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-context-remote" -BuildOutput $output -ComputerName "$computerName"
      }

      AfterAll {
        $computerName = Get-ServerIP
        TearDownBuildContextAndImages -ComputerName "$computerName" `
          -Tags 'pwsh-alpine-remote:latest', 'pwsh-alpine-context-remote:latest'

        Set-Location -Path $initialPath
      }
    }

    Context "[SUCCESS] Build image on remote host with custom Dockerfile directory." {

      BeforeAll {
        SetupCustomBuildContext
      }

      It "builds image in the Dockerfile directory without context settings" {
        $computerName = Get-ServerIP
        $output = Build-DockerImage -Dockerfile "./test/resources/pwsh-alpine/Dockerfile.no-context" `
          -Tag "pwsh-alpine-remote:latest" `
          -Context . `
          -ComputerName "$computerName" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-remote" -BuildOutput $output -ComputerName "$computerName"
      }

      It "builds image with context directory" {
        $computerName = Get-ServerIP
        $output = Build-DockerImage -Dockerfile "./test/resources/pwsh-alpine/Dockerfile.context" `
          -Tag "pwsh-alpine-context-remote:latest" `
          -Context "./custom/context/" `
          -ComputerName "$computerName" 2>&1

        AssertDockerBuildSuccess -Tag "pwsh-alpine-context-remote" -BuildOutput $output -ComputerName "$computerName"
      }

      AfterAll {
        $computerName = Get-ServerIP
        TearDownBuildContextAndImages -ComputerName "$computerName" `
          -Tags 'pwsh-alpine-remote:latest', 'pwsh-alpine-context-remote:latest'
      }
    }
  }
}
