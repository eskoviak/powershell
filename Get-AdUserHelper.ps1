Import-Module ImportExcel

$datafile = 'C:\Users\edskov\Downloads\SCCM Update.xlsx'

if(Test-Path $datafile) {
    $data = Import-Excel -Path $datafile -WorksheetName 'Normalized Data'
    Write-Output ("Rows read: $($data.Length)")
    foreach ($row in $data) {
        $skip = $false
        $CompletionDt = $row.CompletionDt
        if ($CompletionDt -ne [String]::Empty) { continue }
        $samAccountName = $row.Name.split('-')[0]
        $userData = (Get-ADUser -Filter {SamAccountName -like $samaccountname})
        $UserPrincipalName = $userData.UserPrincipalName
        $DistinguishedName = $userData.DistinguishedName
        if ($DistinguishedName -like '*OU=STJ*') {
            $Notes = 'OU=SJH'
            $Skip = $true
        }
        Write-Output $samAccountName, $UserPrincipalName, $DistinguishedName, $Notes, $CompletionDt
    }
} else {
    Write-Output ("File $($TestPath) not found")
}