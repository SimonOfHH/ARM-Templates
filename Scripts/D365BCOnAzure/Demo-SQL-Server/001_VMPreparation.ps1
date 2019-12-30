[cmdletbinding()]
param(
    [string]
    $DownloadPath,
    [string]
    $BCVersion,
    [string]
    $BCCumulativeUpdate,
    [string]
    $BCLanguage,
    $VMAdminUser,
    $VMAdminPass,
    $DomainName
)
Write-Verbose "Starting Transcript"
Start-Transcript -Path (Join-Path $DownloadPath "Log.txt") | Out-Null

$ErrorActionPreference = "Stop"

. .\002_InstallModules.ps1
Write-Verbose "Calling Set-LocalModules"
Set-LocalModules -Verbose

. .\003_ConfigureSQL.ps1
Write-Verbose "Calling Set-SqlServerConfiguration"
Set-SqlServerConfiguration -VmAdminUser $VMAdminUser -VmAdminPass $VMAdminPass -DomainName $DomainName -Verbose

. .\004_DownloadAndExtractBC.ps1
Write-Verbose "Calling Get-AndExtractBusinessCentral"
Get-AndExtractBusinessCentral -BCVersion $BCVersion -BCCumulativeUpdate $BCCumulativeUpdate -BCLanguage $BCLanguage -DownloadDirectory $DownloadPath -Verbose

. .\005_RestoreSampleDB.ps1
Write-Verbose "Calling Install-SampleDatabase"
Install-SampleDatabase -VmAdminPass $VMAdminPass -VmAdminUser $VMAdminUser -DomainName $DomainName -InstallDirectory 

Stop-Transcript