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
    param (                
        $Packages = @('sysinternals')
    )
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

    $modulesToInstall = @("Cloud.Ready.Software.NAV", "Az", "AzTable", "D365BCDownloadHelper", "D365BCOnAzureHelper")
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

    Write-Verbose "Installing Chocolatey"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Write-Verbose "Installing Chocolatey..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    $chocoPath = "C:\ProgramData\chocolatey\bin\choco.exe"
    foreach ($package in $Packages) {
        Write-Verbose "Install Chocolatey-Package $package..."
        & $chocoPath install -y -r $package
    }    
    Write-Verbose "Done"
}