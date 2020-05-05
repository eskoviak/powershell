$username = "eskoviak@eskoviak.net"
$password = "D3nv3rC010"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-SPOService -Url https://eskoviak-admin.sharepoint.com -Credential $cred