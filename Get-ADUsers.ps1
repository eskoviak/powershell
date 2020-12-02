<##
    Base Types
#>

<## RWSCUsers #>
$UserSource = @"
public class User {
    public string DistinguishedName { get; set; }
    public string GivenName { get; set; }
    public string Surname {get; set; }
    public string Name { get { return this.DistinguishedName.Split(",")[0].Split('=')[1]; } }
    public string Description { get; set; }
    public string UserPrincipalName { get; set; }
    public string SamAccountName { get; set; }
}
"@
Add-Type -TypeDefinition $UserSource

$UserProperties = ('GivenName', 'Surname', 'Name', 'Description', 'UserPrincipalName', 'SamAccountName')
$UserSearchBase = 'OU=Houston,OU=RWSCUsers,DC=RWSC,DC=Net'
$Users = @()

Get-ADUser -Filter * -SearchBase $UserSearchBase -Properties $UserProperties | ForEach-Object {
    $User = New-Object User
    $User.DistinguishedName = $_.DistinguishedName
    $User.GivenName = $_.GivenName
    $User.Surname = $_.Surname
    $User.Description = $_.Description
    $User.UserPrincipalName = $_.UserPrincipalName
    $User.SamAccountName = $_.SamAccountName
    $Users += $User
}


