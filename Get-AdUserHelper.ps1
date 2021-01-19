Import-Module ImportExcel

$datafile = 'C:\Users\edskov\Downloads\New List for SCCM Remediation.xlsx'
$outputfile = 'C:\Users\edskov\Documents\Excel\RemediationList-1.xlsx'

Add-Type -TypeDefinition @"
using System;

public class ExcelRow {
    public string DistinguishedName { get; set; }
    public string SamAccountName { get; set; }
    public string OU { get; set; }
    public string UserPrincipalName { get; set; }
    public string CompletionDt { get; set; }
    public string Notes { get; set; }
    // public bool Skip { get; set; }

}
"@

$ExcelRows = @()
if(Test-Path $datafile) {
    $data = Import-Excel -Path $datafile -WorksheetName 'Sheet2'
    Write-Output ("Rows read: $($data.Length)")
    foreach ($row in $data) {
        $rowOut = New-Object ExcelRow
        $notes = [String]::Empty
        $samAccountName = $row.'Device name'.split('-')[0]
        $userData = (Get-ADUser -Filter {SamAccountName -like $samaccountname})
        $UserPrincipalName = $userData.UserPrincipalName
        if ($UserPrincipalName.Length -eq 0) {
            $Notes = 'Not an user account'
        }
        $DistinguishedName = $userData.DistinguishedName
        if ($null -ne $DistinguishedName ) {
            $DNArray = $DistinguishedName.Split(',')
            $rowOut.OU = $DNArray[1]
        } else {
            $rowOut.OU = [String]::Empty  
        }
        ##if ($DistinguishedName -like '*OU=STJ*') {
        ##    $Notes = 'OU=SJH'
        ##    $Skip = $true
        ##}
        
        $rowOut.DistinguishedName = $DistinguishedName
        $rowOut.SamAccountName  = $samAccountName
        $rowOut.UserPrincipalName = $UserPrincipalName
        $rowOut.CompletionDt = $null
        $rowOut.Notes = $notes
        $ExcelRows += $rowOut

        
        #Write-Output $samAccountName, $UserPrincipalName, $DistinguishedName, $Notes, $CompletionDt,$DNArray[1]
    }
    Export-Excel -Path $outputfile -InputObject $ExcelRows -WorksheetName 'Client List'
} else {
    Write-Output ("File $($datafile) not found")
}