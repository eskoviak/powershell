<##
    .synopsis
        Reads the device name, and if found updateds the Complete date with the whenCreated property from the computer
        record

#>
import-module  ImportExcel

#Set-Alias -Name gac -Value ./Get-ADComputers.ps1
$ExcelFile = 'C:\Users\edskov\Documents\Excel\AD User List_with_device_status Master.xlsx'
$ADComputers = Get-ADComputer -Filter * -Properties Whencreated

function Get-ADComputerInfo {
    param (
        # The device name to search for
        [Parameter(mandatory=$true,valuefrompipeline=$true)]
        [String]
        $DeviceName
    )

    if ($DeviceName -eq '---') { return '---' }
    if ($ADComputers.Length -gt 0) {
        $ADComputers | ForEach-Object {
                if ( $_.Name -like $DeviceName ) {
                    return $_.Whencreated
                }
        }
    } else {
        return ""
    }
}

<## (If __name__ == '__main__')#>
if(Test-Path $ExcelFile) {
    $Details = Import-Excel -Path $ExcelFile -Worksheet Workstations  
    Write-Host "No. Computers: $($ADComputers.Length)"
    
    foreach ($row in $Details) {
        Write-Host "Processing $($row.'Device Name' ) : " -NoNewLine
        $result = Get-ADComputerInfo $row.'Device Name'
        Write-Host ( $result ) -NoNewLine
        if ($result -ne "") {
            $updateRow = $details | Where-Object { $_.'Device Name' -eq $row.'Device Name'}
            $updateRow.'Completed Date' = $result
            Write-Output ($updateRow)
            exit
        } else {
            write-output ("")
        }
    }

} else {
    Write-Host "File $($ExcelFile) not found"
}