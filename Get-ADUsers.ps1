<##
    Base Types
#>
$UserSource = @"
public class User {
    public string GivenName { get; set; }
    public string Surname {get; set; }
}
"@
Add-Type -TypeDefinition $UserSource

$UserProperties = ('GivenName', 'Surname', 'Name', 'Description', 'UserPrincipalName', 'SamAccountName')
$SearchBase = 'OU=Houston,OU=RWSCUsers,DC=RWSC,DC=Net'
$Users = @()

Get-ADUser -Filter * -SearchBase $SearchBase -Properties $UserProperties | ForEach-Object {
    $User = New-Object User
    $User.GivenName = $_.GivenName
    $User.Surname = $_.Surname
    $Users += $User
}

foreach ($item in $Users) {
    Write-Host('{0}:{1}' -f  $item.GivenName, $item.Surname) 
}
