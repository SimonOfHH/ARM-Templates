function Get-AndExtractBusinessCentral {
    [CmdletBinding()]
    param (                
        $BCVersion,
        [string]
        $BCCumulativeUpdate,
        [string]
        $BCLanguage,
        [string]
        $DownloadDirectory = "C:\Install\"
    )
    Write-Verbose "Checking if NuGet is installed..."
    Import-Module D365BCDownloadHelper
    Write-Verbose "Version: $BCVersion CU: $BCCumulativeUpdate Lang: $BCLanguage..."
    Get-ReceiveAndExpandBusinessCentralDVD -Version $BCVersion -CumulativeUpdate $BCCumulativeUpdate -Language $BCLanguage -Verbose:$Verbose
    Write-Verbose "Done"
}