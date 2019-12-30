function Set-SqlServerConfiguration {
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
            $DomainName
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

        $sqlServer = new-object ('Microsoft.SqlServer.Management.Smo.Server') $env:computername        
        Get-Service -Name MSSQLSERVER | Restart-Service -Force
        $SQLLogin = [Microsoft.SqlServer.Management.Smo.Login]::New($sqlServer, "$DomainName\$SqlUser")
        $SQLLogin.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::WindowsUser
        $SQLLogin.PasswordPolicyEnforced = $False
        $SQLLogin.Create((ConvertTo-SecureString $SqlPass -AsPlainText -Force))
        $svrole = $sqlServer.Roles | Where-Object { $_.Name -eq 'sysadmin' };
        $svrole.AddMember("$DomainName\$SqlUser");
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