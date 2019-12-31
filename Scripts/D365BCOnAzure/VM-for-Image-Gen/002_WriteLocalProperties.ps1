<# 
 .Synopsis
  Write Subscription information to a local file on the VM
 .Description
  This CmdLet will take all given parameters and write them to a local file on the VM (default: C:\Install\AutoUpdate\Properties.ps1). These information are later used
  to connect to the Storage Account from within the VM, without having to provide actual credentials (the machines or Scale Set resp. have a system assigned identity which grant
  access to the necessary values)
#>
function Set-LocalProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $TargetPath = 'C:\Install\AutoUpdate',
        [Parameter(Mandatory = $false)]
        [string]
        $VMName,
        [Parameter(Mandatory = $false)]
        [string]
        $ScaleSetName,
        [Parameter(Mandatory = $true)]
        [string]
        $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string]
        $StorageAccountName,
        [Parameter(Mandatory = $true)]
        [string]
        $KeyVaultName,
        [Parameter(Mandatory = $true)]
        [string]
        $StorageTableNameSetup,
        [Parameter(Mandatory = $true)]
        [string]
        $StorageTableNameEnvironments,
        [Parameter(Mandatory = $true)]
        [string]
        $StorageTableNameEnvironmentDefaults,
        [Parameter(Mandatory = $true)]
        [string]
        $StorageTableNameInfrastructureData
    ) 
    Write-Verbose "Creating Directory $TargetPath (if not existing)"
    New-Item -ItemType Directory -Path $TargetPath -ErrorAction SilentlyContinue | Out-Null
    $fullscriptpath = Join-Path $TargetPath 'Properties.ps1'
    Write-Verbose "Fullpath to local properties set to $fullscriptpath"

    $content = "
    `$VMName = '$VMName'
    `$ScaleSetName = '$ScaleSetName'
    `$ResourceGroupName = '$ResourceGroupName'
    `$StorageAccountName = '$StorageAccountName'
    `$KeyVaultName = '$KeyVaultName'
    `$StorageTableNameSetup = '$StorageTableNameSetup'
    `$StorageTableNameEnvironments = '$StorageTableNameEnvironments'
    `$StorageTableNameEnvironmentDefaults = '$StorageTableNameEnvironmentDefaults'
    `$StorageTableNameInfrastructureData = '$StorageTableNameInfrastructureData'
    "
    Write-Verbose "Writing the following Content to file $fullscriptpath `n$content"
    Set-Content -Path $fullscriptpath -Value $content
}