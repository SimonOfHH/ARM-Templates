function Set-ScheduledTask {
    [CmdletBinding()]
    param (                
        [string]
        $TargetFolder = 'C:\Install\AutoUpdate'        
    )    
    New-Item -ItemType Directory -Path $targetFolder -ErrorAction SilentlyContinue | Out-Null
    
    $fullscriptpath = Join-Path $targetFolder 'AutoUpdate.ps1'
    
    $scriptblock = {
        try {
            Stop-Transcript | out-null
        }
        catch {
            $error.clear()
        }
        Start-Transcript -Path "C:\Install\Log\AutoUpdate.$(get-date -format yyyyMMddhhmmss).log"        
        if (Get-Module -Name D365BCOnAzureHelper -ListAvailable) {
            Update-Module -Name D365BCOnAzureHelper -Force
        }
        else {
            Install-Module -Name D365BCOnAzureHelper -Force
        }
        Import-Module -Name D365BCOnAzureHelper
        
        . ("C:\Install\AutoUpdate\Properties.ps1")
        $Instance = $false
        if (-not([string]::IsNullOrEmpty($VMName))) {
            $ObjectName = $VMName
        }
        else {
            $ObjectName = $ScaleSetName
            $Instance = $true
        }
        $autoUpdateParam = @{
            ObjectName                          = $ObjectName
            IsScaleSet                          = $Instance 
            ResourceGroupName                   = $ResourceGroupName 
            StorageAccountName                  = $StorageAccountName
            KeyVaultName                        = $KeyVaultName
            StorageTableNameSetup               = $StorageTableNameSetup
            StorageTableNameEnvironments        = $StorageTableNameEnvironments
            StorageTableNameEnvironmentDefaults = $StorageTableNameEnvironmentDefaults 
            StorageTableNameInfrastructureData  = $StorageTableNameInfrastructureData
        }
        Start-CustomVMUpdate @autoUpdateParam
        Stop-Transcript
    }
    
    Set-Content -Path $fullscriptpath -Value $scriptblock
    
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
        -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Unrestricted -File `"$fullscriptpath`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $taskPrinicpal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType  ServiceAccount -RunLevel Highest
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $taskPrinicpal -TaskName "CustomAutoUpdate" -Description "Update Azure Machine (D365)" | Out-Null
}