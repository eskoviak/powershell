Import-Module ImportExcel


$Records = @()
$Users = Get-ADUser -Filter {Enabled -eq $true}  -Properties Description -SearchBase "OU=RWSCUsers,DC=rwsc,DC=net"

Write-Output ('Processing OU=RWSCUsers,DC=rwsc,DC=net' )
$Users | ForEach-Object {

    $output = New-Object -TypeName psobject
    Add-Member -InputObject $output -MemberType NoteProperty -Name Distinguished -Value $_.DistinguishedName
    Add-Member -InputObject $output -MemberType NoteProperty -Name CN -Value ""
    Add-Member -InputObject $output -MemberType NoteProperty -Name GivenName -Value $_.GivenName
    Add-Member -InputObject $output -MemberType NoteProperty -Name SurName -Value $_.SurName
    Add-Member -InputObject $output -MemberType NoteProperty -Name Location -Value ""
    Add-Member -InputObject $output -MemberType NoteProperty -Name Description -Value $_.Description
    Add-Member -InputObject $output -MemberType NoteProperty -Name UserSamAccountName -Value $_.SamAccountName
    Add-Member -InputObject $output -MemberType NoteProperty -Name ComputerSamAccountName -Value ""
    Add-Member -InputObject $output -MemberType NoteProperty -Name AbsoluteStatus -Value ""
    
    $Records += $output
}

Write-Output ('Read {0} Records from OU RWSCUsers' -f $Records.Length)

Write-Output('Processing OU=Sales,DC=rwsc,DC=net')
$Users = Get-ADUser -Filter {Enabled -eq $true}  -Properties Description -SearchBase "OU=Sales,DC=rwsc,DC=net"
$count = 0

$Users | ForEach-Object {

    $output = New-Object -TypeName psobject
    Add-Member -InputObject $output -MemberType NoteProperty -Name Distinguished -Value $_.DistinguishedName
    Add-Member -InputObject $output -MemberType NoteProperty -Name CN -Value ""
    Add-Member -InputObject $output -MemberType NoteProperty -Name GivenName -Value $_.GivenName
    Add-Member -InputObject $output -MemberType NoteProperty -Name SurName -Value $_.SurName
    Add-Member -InputObject $output -MemberType NoteProperty -Name Location -Value ""
    Add-Member -InputObject $output -MemberType NoteProperty -Name Description -Value $_.Description
    Add-Member -InputObject $output -MemberType NoteProperty -Name UserSamAccountName -Value $_.SamAccountName
    Add-Member -InputObject $output -MemberType NoteProperty -Name ComputerSamAccountName -Value ""
    Add-Member -InputObject $output -MemberType NoteProperty -Name AbsoluteStatus -Value ""
    
    $Records += $output
    $count += 1
}

Write-Output ('Read {0} Records from OU Sales' -f $count)

$Records | Export-Excel

