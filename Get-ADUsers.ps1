$UserSearchBase = 'OU=Houston,OU=RWSCUsers,DC=RWSC,DC=Net'
$Users = Get-ADUser -Filter *  -SearchBase $UserSearchBase

$Users | ForEach-Object {
    Write-Output ( 'Name: {0}' -f $_.DistinguishedName )
}
