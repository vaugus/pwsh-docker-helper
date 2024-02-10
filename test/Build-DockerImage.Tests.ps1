$ModulePath = Join-Path ($MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent) "src/DockerHelper"

Import-Module $ModulePath

InModuleScope DockerHelper {

  Describe "Build-DockerImage" {

    Context "[SUCCESS] Build image on localhost in the directory where Dockerfile resides." {

      BeforeAll {
        $initialPath = Get-Location
        Set-Location -Path (Join-Path -Path $initialPath -ChildPath "tests/resources/pwsh-alpine/")
        New-Item -Path "./custom/context" -ItemType Directory

        $pwshTar = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-musl-x64.tar.gz"
        Invoke-WebRequest $pwshTar -OutFile "./custom/context/powershell.tar.gz"
      }

      It "builds image in localhost in the Dockerfile directory without context settings" {
        $buildOutput = Build-DockerImage -Dockerfile "Dockerfile.no-context" `
          -Tag "pwsh-alpine:latest" `
          -Context . 2>&1

        $LASTEXITCODE | Should -BeExactly 0
        $buildOutput | Should -Not -Be $null
        (docker images | Select-String "pwsh-alpine" -Quiet) | Should -BeTrue
      }

      It "builds image in localhost in the Dockerfile directory with context directory" {

        $buildOutput = Build-DockerImage -Dockerfile Dockerfile.context `
          -Tag "pwsh-alpine-context:latest" `
          -Context "./custom/context/" 2>&1

        $LASTEXITCODE | Should -BeExactly 0
        $buildOutput | Should -Not -Be $null
        (docker images | Select-String "pwsh-alpine-context" -Quiet) | Should -BeTrue
      }

      AfterAll {
        Set-Location -Path $initialPath
        docker rmi pwsh-alpine:latest pwsh-alpine-context:latest
        Remove-Item "tests/resources/pwsh-alpine/custom" -Recurse -Force
      }
    }
  }
}
