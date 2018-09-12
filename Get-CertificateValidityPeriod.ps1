# -------------------------------------------------------- #
# Created at: 2018-09-12
# Author: Michael Roef (microef)
# Contact: hello@michaelroef.me
# Website: http://michaelroef.me
# -------------------------------------------------------- #
# Get-CertificateValidityPeriod
# Check website SSL certifcate and get the validity period
# For example:
# ./Get-CertificateValidityPeriod.ps1 -websites telenet.be, google.be
# -------------------------------------------------------- #

param(
    [Parameter(Mandatory=$true)]
    [string[]]$websites
)

# Import the certificate info module (Force changes)
Import-Module './Modules/Get-SslCertificateInfo.psm1' -Force

foreach($website in $websites)
{
    try {
        # Get the info
        $sslInfo = Get-SslCertificateInfo -domain $website

        if($sslInfo)
        {
            $info = [ordered]@{}
            $info.Domain = $sslInfo.Domain
            $ts = New-TimeSpan -Start (Get-Date).ToString() -End $sslInfo.Certificate.NotAfter
            $info.'Valid Days' = $ts.Days
            
            New-Object –TypeName PSObject –Prop $info   
        }
    }
    catch {
        # Check failed
    }
}