Import-Module (Join-Path (Get-Location) "test/TestUtils")

Describe -Name "Remote Server Smoke Tests" -Tags @("smoke") {

  Context "[SUCCESS] Remote Server starts, becomes accessible, and stops correctly." {

    BeforeAll {
      $remoteServerStartupLogs = (SetupRemoteServer 2>&1) -join "`n"
      $remoteServerStartupLogs | Should -Not -BeNullOrEmpty
      $remoteServerStartupLogs | Should -Match "Server listening on 0.0.0.0 port 2222."
    }

    It "allows ssh connections" {
      $serverIP = Get-ServerIP

      $sshOutput = (ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes `
        -i test/resources/server/docker_helper -p 2222 `
        root@"$serverIP" "cat /etc/os-release | grep PRETTY_NAME") -join "`n"

      $sshOutput | Should -Not -BeNullOrEmpty
      $sshOutput | Should -Be 'PRETTY_NAME="Alpine Linux v3.19"'
    }

    AfterAll {
      TearDownRemoteServer
      (docker container ls -a | Select-String "server" -Quiet) | Should -BeNullOrEmpty
    }
  }
}
