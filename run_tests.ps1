Import-Module "./test/TestUtils"

SetupRemoteServer

$configuration = New-PesterConfiguration
$configuration.Output.Verbosity = 'Detailed'
$configuration.Filter.ExcludeTag = 'smoke'

Invoke-Pester -Configuration $configuration

TearDownRemoteServer
