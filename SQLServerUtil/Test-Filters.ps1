$FileName = '.\data\Red_Wing_Import_Status_Report_20200325112155.csv'

$rawData = Get-Content -Path $FileName

## Strip Header row and add a contrived (but useful) header
$rawData[1..$rawData.Count] | Out-File -FilePath ./temp.csv -Force
$rawCSVObj = Import-Csv -Path ./temp.csv -Header 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V'
Remove-Item -Path ./temp.csv

$processedList = 0
$recordCount = 0
foreach ($irow in $rawCSVObj) {
    $recordCount += 1
    if (($irow.H.length -eq 0) -or ($irow.J.length -eq 0) -or ($irow.N.length -eq 0) -or ($irow.O.length -eq 0) ) {
        Write-Output ("found missing data {0}" -f ($recordCount))
        continue
    }
    if (($irow.H -match '.*[,].*') -or ($irow.J -match '.*[,].*') ) {
        Write-Output ("found illegal character: {0}" -f $irow)
        continue
    }
    if ( -not ($irow.J -match  '^\d{5}[A-Z]')) {
        Write-Output ("found bad ItemNum: {0}" -f $irow.J)
        continue
    }
    $processedList += 1
}
$recordCount
$processedList
