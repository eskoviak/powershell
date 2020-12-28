$excel = New-Object -ComObject Excel.Application

$workbook = $excel.Workbooks.Open("C:\Users\edskov\Documents\Excel\AD User List_with_device_status Master.xlsx")
$details = $workbook.Worksheets("Details")

$deviceTable = $details.Columns("I:M")
Write-host ("Number of columns: $($deviceTable.Count)")
Write-host("$($deviceTable.Address)")

<##
$count = 0

foreach( $row in $deviceTable ) {
    write-host ($row)
    $count += 1
    if ($count -gt 800) { break }
}

Write-Host( $workbook.Sheets.Count)
Write-Host ( ps | Where {$_.ProcessName -eq 'EXCEL'} | Select ProcessName, Id)
Read-Host -Prompt "Press any key to continue..."
#>

foreach ($wb in $excel.Workbooks) {
    $wb.Save()
}
$excel.Quit()
Write-Host ( ps | Where {$_.ProcessName -eq 'EXCEL'} | Select ProcessName, Id)

