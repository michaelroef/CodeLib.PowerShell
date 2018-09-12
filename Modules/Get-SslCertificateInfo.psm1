# -------------------------------------------------------- #
# Created at: 2018-09-12
# Author: Michael Roef (microef)
# Contact: hello@michaelroef.me
# Website: https://michaelroef.me
# -------------------------------------------------------- #
# Get-SslCertificateInfo
# Get SSL certificate info for given domain (web url)
# For example:
# Import-Module './Modules/Get-SslCertificateInfo.psm1' -Force
# Get-SslCertificateInfo -domain google.be
# -------------------------------------------------------- #

function Get-SslCertificateInfo {
    param ([Parameter(Mandatory=$true)]$domain)
    begin {
        # Get all available SSL protocols that we can use to test if the server can handle it
        $sslProtocols = [System.Security.Authentication.SslProtocols] |
            Get-Member -Static -MemberType Property |
            Where-Object -Filter { $_.Name -notin @("Default","None") } |
            Foreach-Object { $_.Name }
    }
    process {
        # Generate hashtable to store data
        $sslResult = [Ordered]@{}
        $sslResult.Add("Domain", $domain)
        $sslResult.Add("Certificate", $null)
        # Certificate
        $certificate = $null;
        # Check every SSL protocol
        ForEach($sslProtocol in $sslProtocols)
        {
            # Create socket connection
            $socket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
            $socket.Connect($domain, 443)
            try {
                #Create streams
                $netStream = New-Object System.Net.Sockets.NetworkStream($socket, $true)
                $sslStream = New-Object System.Net.Security.SslStream($netStream, $true)
                # Test if the protocol authentication is enabled on the server
                $sslStream.AuthenticateAsClient($domain,  $null, $sslProtocol, $false)
                $sslResult.Add($sslProtocol, $true)
                # Get certificate
                $certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]$sslStream.RemoteCertificate
            } catch  {
                $sslResult.Add($sslProtocol, $false)
            } finally {
                $SslStream.Close()
            }
        }

        If($certificate)
        {
            $sslResult["KeyLength"] = $certificate.PublicKey.Key.KeySize
            $sslResult["SignatureAlgorithm"] = $certificate.SignatureAlgorithm.FriendlyName
            $sslResult["Certificate"] = $certificate
        }

        [PSCustomObject]$sslResult
    }
}