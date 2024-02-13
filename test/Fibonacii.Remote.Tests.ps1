
Describe -Name "Get-Fibonacci" -Tags @("feyes") {

  Context "Build and run the fibonacci docker image on the local host." {

    BeforeAll {
      Build-DockerImage -Dockerfile "./fibonacci/Dockerfile" `
        -Tag "fibonacci:latest" `
        -Context "./fibonacci/" `
    }

    It "runs the fibonacci script without parameters" {
      Run-DockerContainer -ImageName "fibonacci:latest" `
        -DockerParams "-d", "--name=fibonacci" 
        
      Start-Sleep -Seconds 6
      docker stop fibonacci
      (docker logs fibonacci) -join "," | Should -Match "0,1,1,2,3,5,8,13,21,34"
    }

    AfterEach {
      docker kill fibonacci 2>&1 > /dev/null
      docker container rm fibonacci
    }

    It "runs the fibonacci script with parameters" {
      Run-DockerContainer -ImageName "fibonacci:latest" `
        -DockerParams "-eNUMBER=10", "--name=fibonacci" 
        
      Start-Sleep -Seconds 2
      $logs = (docker logs fibonacci)
      $logs -join "," | Should -Match "34"
      $logs.Count | Should -BeExactly 1
    }

    AfterEach {
      docker kill fibonacci 2>&1 > /dev/null
      docker container rm fibonacci
    }
  }
}
