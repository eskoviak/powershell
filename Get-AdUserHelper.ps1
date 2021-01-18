Import-Module ImportExcel

$datafile = 'C:\Users\edskov\Downloads\SCCM Update.xlsx'
$outputfile = 'C:\Users\edskov\Documents\Excel\RemediationList.xlsx'
Add-Type -TypeDefinition @"
using System;

public class ExcelRow {
    public string DistinguishedName { get; set; }
    public string SamAccountName { get; set; }
    public string UserPrincipalName { get; set; }
    public string CompletionDt { get; set; }
    public string Notes { get; set; }
    public bool Skip { get; set; }

}
"@

$emailBody = @"
RWSC User--

Over the course of the next few days, it will be necessary for one of our Help Desk Technicians to remote into your work device to perform software maintenance.

This activity will not require any action on your part.  The technician will attempt to contact you prior to starting the activity via Teams.  If you plan on
being away from your machine, please leave it connected to the internet, powered on, and unlocked.  Thank you in advance for your cooperation.  --IT Help Desk
"@

$ExcelRows = @()

if(Test-Path $datafile) {
    $data = Import-Excel -Path $datafile -WorksheetName 'Normalized Data'
    Write-Output ("Rows read: $($data.Length)")
    foreach ($row in $data) {
        $rowOut = New-Object ExcelRow
        $skip = $false
        $notes = [String]::Empty
        $CompletionDt = $row.CompletionDt
        if ($CompletionDt -ne [String]::Empty) { continue }
        $samAccountName = $row.Name.split('-')[0]
        $userData = (Get-ADUser -Filter {SamAccountName -like $samaccountname})
        $UserPrincipalName = $userData.UserPrincipalName
        if ($UserPrincipalName.Length -eq 0) {
            $Notes = 'Not an user account'
            $skip = $true
        }
        $DistinguishedName = $userData.DistinguishedName
        if ($DistinguishedName -like '*OU=STJ*') {
            $Notes = 'OU=SJH'
            $Skip = $true
        }
        $rowOut.DistinguishedName = $DistinguishedName
        $rowOut.SamAccountName  = $samAccountName
        $rowOut.UserPrincipalName = $UserPrincipalName
        $rowOut.CompletionDt = $CompletionDt
        $rowOut.Notes = $notes
        $rowOut.Skip = $skip
        $ExcelRows += $rowOut

        #Write-Output $samAccountName, $UserPrincipalName, $DistinguishedName, $Notes, $CompletionDt,$skip
    }
    Export-Excel -Path $outputfile -InputObject $ExcelRows -WorksheetName 'Client List'
} else {
    Write-Output ("File $($TestPath) not found")
}