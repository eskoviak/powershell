<##
$output = New-Object -TypeName psobject
Add-Member -InputObject $output -MemberType NoteProperty -Name Distinguished -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name CN -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name GivenName -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name SurName -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name Location -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name Description -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name UserSamAccountName -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name ComputerSamAccountName -Value ""
Add-Member -InputObject $output -MemberType NoteProperty -Name AbsoluteStatus -Value ""
#>



$found = $false

$ADComputers | ForEach-Object {
        if ( $_.Name -like $row.'Device Name' ) {
            if ($found) {
                " *" | Write-Host -NoNewLine
            }
            Write-Host "$($_.Name)`t$($_.Whencreated)" -NoNewLine
            $found = $true
        }
}
Write-Host ""
