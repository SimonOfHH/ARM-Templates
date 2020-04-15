[cmdletbinding()]
param(
    [string]
    $VMName,
    [string]
    $ScaleSetName,
    [string]
    $ResourceGroupName,
    [string]
    $StorageAccountName,
    [string]
    $KeyVaultName,
    [string]
    $StorageTableNameInfrastructureData,
    [string]
    $DownloadPath,
    [string]
    $BCVersion,
    [string]
    $BCCumulativeUpdate,
    [string]
    $BCLanguage,
    [ValidateSet('App', 'Web')]
    [string]
    $InstallationType = "App",     
    $VMAdminUser,
    $VMAdminPass
)
Write-Verbose "Starting Transcript"
Start-Transcript -Path (Join-Path $DownloadPath "Log_Image_Preparation.txt") | Out-Null

$ErrorActionPreference = "Stop"

$localProperties = @{
    VMName                              = $VMName
    ScaleSetName                        = $ScaleSetName
    ResourceGroupName                   = $ResourceGroupName
    StorageAccountName                  = $StorageAccountName
    KeyVaultName                        = $KeyVaultName
    StorageTableNameInfrastructureData  = $StorageTableNameInfrastructureData
}
. .\002_WriteLocalProperties.ps1
Write-Verbose "Calling Set-LocalProperties"
Set-LocalProperties @localProperties -Verbose

. .\003_InstallModules.ps1
Write-Verbose "Calling Set-LocalModules"
Set-LocalModules -Verbose

. .\004_DownloadAndExtractBC.ps1
Write-Verbose "Calling Get-AndExtractBusinessCentral"
Get-AndExtractBusinessCentral -BCVersion $BCVersion -BCCumulativeUpdate $BCCumulativeUpdate -BCLanguage $BCLanguage -DownloadDirectory $DownloadPath -Verbose

$dvdPath = Join-Path $DownloadPath "DVD"
$bcInstallArgs = @{
    DownloadDirectory = $dvdPath
    Version           = $BCVersion
    InstallationType  = $InstallationType
    VMAdminUser       = $VMAdminUser
    VMAdminPass       = $VMAdminPass
}
. .\005_InstallBC.ps1
$ErrorActionPreference = "Continue"
Write-Verbose "Calling Install-BusinessCentralStarter"
Install-BusinessCentralStarter @bcInstallArgs -Verbose
$ErrorActionPreference = "Stop"

. .\006_CreateScheduledTask.ps1
Write-Verbose "Calling Set-ScheduledTask"
Set-ScheduledTask

Stop-Transcript