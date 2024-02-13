#!/usr/bin/pwsh

function Get-Fibonacci($n) {
  if ($n -eq 1) {
    Write-Output 0
  }

  $currentValue = 1
  
  $count = 1
  $currentValue..$n | foreach-object { 
      $tmp = $currentValue
      $currentValue = $currentValue + $next
      $next = $tmp
      $count++
      if ($count -eq $n) {
        Write-Output $next
      }
  }
}

function Get-NumberInSequence($sequenceIndex) {
  return (Get-Fibonacci $sequenceIndex)
}

function Get-SequenceWithoutParameters {
  $sequenceIndex = 1
  while($true) {
    Write-Host (Get-NumberInSequence $sequenceIndex)
    $sequenceIndex++
    Start-Sleep -Seconds 0.5
  }
}

if ([string]::isNullOrEmpty($env:NUMBER)) {
  Get-SequenceWithoutParameters
} else {
  Get-NumberInSequence ([int] $env:NUMBER)
}
