Import-Module (Join-Path (Get-Location) "test/TestUtils")

$DockerHelperPath = Join-Path ($MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent) "src/DockerHelper"
Import-Module $DockerHelperPath

InModuleScope DockerHelper {

  Describe -Name "Copy-Prerequisites" -Tags @("remote") {

    Context "[SUCCESS] Copy file to remote host." {

      It "copies a file to a remote server" {
        $computerName = Get-ServerIP
        $sshOutput = (ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes `
          -i test/resources/server/docker_helper -p 2222 `
          root@"$computerName" "ls /tmp | grep test.ps1") -join "`n"

        $sshOutput | Should -BeNullOrEmpty

        $sessionProperties = @{
          "Port" = 2222
          "UserName" = "root"
          "KeyFilePath" = "test/resources/server/docker_helper"
        }

        $output = Copy-Prerequisites -ComputerName "$computerName" `
          -Path "test/resources/server/docker_helper.pub" `
          -Destination "/tmp/remote.pub" `
          -SessionProperties $sessionProperties 2>&1

        $output | Should -Be $null
        $sshOutput = (ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes `
          -i test/resources/server/docker_helper -p 2222 `
          root@"$computerName" "ls /tmp | grep remote.pub") -join "`n"

        $sshOutput | Should -Be "remote.pub"
      }
    }
  }
}
