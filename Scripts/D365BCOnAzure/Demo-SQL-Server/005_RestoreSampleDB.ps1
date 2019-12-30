function Install-SampleDatabase {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]              
        [string]
        $VmAdminUser,
        [Parameter(Mandatory = $true)]
        [string]
        $VmAdminPass,
        [Parameter(Mandatory = $true)]
        [string]
        $DomainName,
        [Parameter(Mandatory = $true)]
        [string]
        $InstallDirectory,
        [Parameter(Mandatory = $false)]
        [string]
        $SqlAdminUser = $VmAdminUser,
        [Parameter(Mandatory = $false)]
        [string]
        $SqlAdminPass = $VmAdminPass
    )
    $scriptBlock = {
        param(        
            [Parameter(Mandatory = $true)]
            [string]
            $SqlUser,
            [Parameter(Mandatory = $true)]
            [string]
            $SqlPass,
            [Parameter(Mandatory = $true)]
            [string]
            $DomainName,
            [Parameter(Mandatory = $true)]
            [string]
            $InstallDirectory
        )
        $assemblylist =   
        "Microsoft.SqlServer.Management.Common",  
        "Microsoft.SqlServer.Smo",  
        "Microsoft.SqlServer.Dmf ",  
        "Microsoft.SqlServer.Instapi ",  
        "Microsoft.SqlServer.SqlWmiManagement ",  
        "Microsoft.SqlServer.ConnectionInfo ",  
        "Microsoft.SqlServer.SmoExtended ",  
        "Microsoft.SqlServer.SqlTDiagM ",  
        "Microsoft.SqlServer.SString ",  
        "Microsoft.SqlServer.Management.RegisteredServers ",  
        "Microsoft.SqlServer.Management.Sdk.Sfc ",  
        "Microsoft.SqlServer.SqlEnum ",  
        "Microsoft.SqlServer.RegSvrEnum ",  
        "Microsoft.SqlServer.WmiEnum ",  
        "Microsoft.SqlServer.ServiceBrokerEnum ",  
        "Microsoft.SqlServer.ConnectionInfoExtended ",  
        "Microsoft.SqlServer.Management.Collector ",  
        "Microsoft.SqlServer.Management.CollectorEnum",  
        "Microsoft.SqlServer.Management.Dac",  
        "Microsoft.SqlServer.Management.DacEnum",  
        "Microsoft.SqlServer.Management.Utility"  
  
        foreach ($asm in $assemblylist) {  
            $asm = [Reflection.Assembly]::LoadWithPartialName($asm)  
        }

        $path = $InstallDirectory
        $bakFile = ((Get-ChildItem -Path $path -Filter "*.bak" -Recurse) | Select-Object -First 1)
        $backupFile = $bakFile.FullName
        $server = New-Object Microsoft.SqlServer.Management.Smo.Server $env:ComputerName

        $backupDevice = New-Object Microsoft.SqlServer.Management.Smo.BackupDeviceItem($backupFile, 'File')
        $smoRestore = New-Object Microsoft.SqlServer.Management.Smo.Restore

        $DataPath = if ($server.Settings.DefaultFile.Length -gt 0 ) { $server.Settings.DefaultFile } else { $server.Information.MasterDBLogPath }
        $LogPath = if ($server.Settings.DefaultLog.Length -gt 0 ) { $server.Settings.DefaultLog } else { $server.Information.MasterDBLogPath }

        $smoRestore.Devices.Add($backupDevice)
        $smoRestoreDetails = $smoRestore.ReadBackupHeader($server)
        $smoRestore.Database = $smoRestoreDetails.Rows[0]["DatabaseName"]
        $smoRestoreFiles = $smoRestore.ReadFileList($server)

        foreach ($File in $smoRestoreFiles) {
            #Create relocate file object so that we can restore the database to a different path
            $smoRestoreFile = New-Object( "Microsoft.SqlServer.Management.Smo.RelocateFile" )
  
            #the logical file names should be the logical filename stored in the backup media
            $smoRestoreFile.LogicalFileName = $File.LogicalName
 
            $smoRestoreFile.PhysicalFileName = $( if ($File.Type -eq "L") { $LogPath } else { $DataPath } ) + "\" + [System.IO.Path]::GetFileName($File.PhysicalName)
            $smoRestore.RelocateFiles.Add($smoRestoreFile)
        }

        Restore-SqlDatabase -ServerInstance $env:ComputerName -Database $smoRestore.Database -BackupFile $backupFile -RestoreAction Files -ReplaceDatabase -RelocateFile $smoRestore.RelocateFiles
    }
    try {        
        $VMCredentials = New-Object System.Management.Automation.PSCredential ("$($env:computername)\$VmAdminUser", (ConvertTo-SecureString $VmAdminPass -AsPlainText -Force))
        $session = New-PSSession -ComputerName $env:computername -Credential $VMCredentials
        Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $SqlAdminUser, $SqlAdminPass, $DomainName -Session $session
        $session | Remove-PSSession
    }
    catch {
        # Do nothing
    }
}