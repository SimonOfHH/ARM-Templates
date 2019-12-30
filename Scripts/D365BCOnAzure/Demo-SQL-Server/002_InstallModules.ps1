<# 
 .Synopsis
  Installs default modules to the VM
 .Description
  This CmdLet will install some necessary PS-modules and Tools on the machine. 
  PS-Modules:
    NuGet (PackageProvider)
    Cloud.Ready.Software.NAV
    Az
    AzTable
  Tools:
    Chocolatey
      SysInternals-package
#>
function Set-LocalModules {
    [CmdletBinding()]
    param ()
    Write-Verbose "Checking if NuGet is installed..."
    if (-not (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq 'NuGet' })) {
        try {
            Write-Verbose "Installing NuGet..."
            Install-PackageProvider -Name NuGet -Confirm:$False -Force | Out-Null
        }
        catch [Exception] {
            Write-Verbose "Error installing NuGet"
            $_.message 
            exit
        }
    }

    $modulesToInstall = @("D365BCDownloadHelper")
    foreach ($moduleToInstall in $modulesToInstall) {
        if (-not (Get-Module -ListAvailable -Name $moduleToInstall)) {
            try {
                Write-Verbose "Installing Module $moduleToInstall..."
                Install-Module $moduleToInstall -Scope AllUsers -Confirm:$false -Force -SkipPublisherCheck:$true
            }
            catch [Exception] {
                Write-Verbose "Error installing Module $moduleToInstall"
                $_.message 
                exit
            }
        }
    }
    Write-Verbose "Done"
}