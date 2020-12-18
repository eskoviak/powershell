<##
    .synopsis
        Reads the device name, and if found updateds the Complete date with the whenCreated property from the computer
        record

#>
import-module  ImportExcel

#Set-Alias -Name gac -Value ./Get-ADComputers.ps1
$ExcelFile = 'C:\Users\edskov\Documents\Excel\AD User List_with_device_status Master.xlsx'
$ADComputers = Get-ADComputer -Filter * -Properties Whencreated

if(Test-Path $ExcelFile) {
    $Details = Import-Excel -Path $ExcelFile -Worksheet Details
    #Write-Host "No. Computers: $($ADComputers.Length)"
    foreach ($row in $Details) {
        Write-Host "Processing $($row.Name) ( $($row.'3-4 User Name') ) : " -NoNewLine
        $found = $false
        $ADComputers | ForEach-Object {
                if ( $_.Name -like "*" + $row.'3-4 User Name' + "*" ) {
                    if ($found) {
                        " *" | Write-Host -NoNewLine
                    }
                    Write-Host "$($_.Name)" -NoNewLine
                    $found = $true
                }
        }
        Write-Host ""
    }

} else {
    Write-Host "File $($ExcelFile) not found"
}