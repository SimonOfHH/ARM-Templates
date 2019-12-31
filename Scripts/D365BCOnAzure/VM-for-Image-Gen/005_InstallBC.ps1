function Install-BusinessCentralStarter {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false)]
        [string]
        $DownloadDirectory,
        [Parameter(Mandatory = $false)]
        [string]
        $ConfigurationFile,
        [Parameter(Mandatory = $false)]
        [string]
        $LicenseFilename,
        [Parameter(Mandatory = $false)]
        [ValidateSet('13', '14', '15')]
        [string]
        $Version,
        [ValidateSet('App', 'Web')]
        [Parameter(Mandatory = $false)]
        [string]
        $InstallationType = "App",
        [Parameter(Mandatory = $false)]        
        $VMAdminUser,
        [Parameter(Mandatory = $false)]        
        $VMAdminPass
    )
    if ($VMAdminUser) {
        $vmadminPassSecure = ConvertTo-SecureString $VMAdminPass -AsPlainText -Force
        $VMCredentials = New-Object System.Management.Automation.PSCredential ($VMAdminUser, $vmadminPassSecure)
    }
    Write-Verbose "Importing Module D365BCOnAzureHelper"
    Import-Module D365BCOnAzureHelper
    Write-Verbose "Installing Business Central"
    $InstallArgs = @{        
    }
    if (-not([string]::IsNullOrEmpty($DownloadDirectory))) {
        $InstallArgs.Add('DownloadDirectory', $DownloadDirectory)
    }
    if (-not([string]::IsNullOrEmpty($ConfigurationFile))) {
        $InstallArgs.Add('ConfigurationFile', $ConfigurationFile)
    }
    if (-not([string]::IsNullOrEmpty($LicenseFilename))) {
        $InstallArgs.Add('LicenseFilename', $LicenseFilename)
    }
    if (-not([string]::IsNullOrEmpty($Version))) {
        $InstallArgs.Add('Version', $Version)
    }
    if (-not([string]::IsNullOrEmpty($InstallationType))) {
        $InstallArgs.Add('InstallationType', $InstallationType)
    }
    if (-not([string]::IsNullOrEmpty($VMCredentials))) {
        $InstallArgs.Add('VMCredentials', $VMCredentials)
    }
    # This try-catch is used, because the installation might be started using Sysinternals PsExec
    # but PsExec-internal handling always causes to let PowerShell think that an exception occured, even though everything went fine
    try {
        Install-BusinessCentral @InstallArgs
    }
    catch {
        
    }
    Write-Verbose "Finished Installation"
    # Set default Service to disabled
    Get-Service | Where-Object { $_.Name -like 'MicrosoftDynamicsNavServer*' } | Set-Service -StartupType Disabled
    Get-Service | Where-Object { $_.Name -like 'MicrosoftDynamicsNavServer*' } | Stop-Service
}