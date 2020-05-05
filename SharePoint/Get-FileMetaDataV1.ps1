<##
.SYNOPSIS
   Reads meta data from a spreadsheet
   
.PARAMETER

#>
Import-Module ImportExcel
$entries = Import-Excel -Path 'RWS:\Documents\Excel-PowerBI\RWS_EA Team Site Metadata.xlsx' -WorksheetName 'Documents'

foreach($entry in $entries) {
    $entry.TaxKeyword | Write-Output
}
