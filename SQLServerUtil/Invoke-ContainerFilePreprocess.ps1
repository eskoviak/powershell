<##
.synopsis
  Reads the input file from Business area, adds/updates the data 

.description
  The input file is a bit messy -- clean it up
.example
#>

param (
    [CmdletBinding()]

    # Debug
    [Parameter(Mandatory=$false)]
    [switch]
    $IsDebug

)

##### GLOBALS #####
<# The first row contains garbage headers that will cause the import to choke
   For consistency; Assign Letters similar to Excel Default Column Names; these
   will be used in the JSON mapping file
#>
##
## TODO Convert to appconfig.json
##
$Headers =  'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V'
$SourceFolder = "\\websense\ftproot\UPS\Containers"
$SourceFileRegex = '\d{4}.csv$'
#$DebugFile = 'data\Red_Wing_Import_Status_Report_20200429094653.csv'
#$DatabaseName = "PurchaseOrderContainer"
#$TableName = "PurchaseOrderContainer"
#$ConnectionString = "Server=SQL12DEV\SQL2;database=$DatabaseName;Integrated Security=true"

<##
  Read the raw file, Delete the header row and save to a 
  temp file with the new header row
#>
#$ScriptPath = $MyInvocation.PSScriptRoot
$Filelist = $null
if ($IsDebug) {
    $Filelist = Get-ChildItem -Path (Join-Path -Path (Split-Path -Path $PSCommandPath) -Childpath data) -Filter *.csv
    #Write-Output($FileList)
} else {
    $FileList = Get-ChildItem -Path $SourceFolder -Filter *.csv
    #Write-Output (" : $FileList")
}

if ($Filelist -eq $null ) {
    Write-Host ("No files to process -- Exiting...")
    Exit
}

foreach($file in $Filelist) {
    if ($file -match $SourceFileRegex ) {
        Write-Host ("Processing $File")
    } else {
        Write-Host ("Skipping $file")
    }
}
Exit

foreach ($file in (GET-Item -Path $SourceFolder -Include *.csv)){
    if ($file -match $SourceFileRegex) {
        Write-Output ("")
    }
}
$rawData = Get-Content -Path $FileName
if($IsDebug) {
    # Just a sample to test with; eliminates the garbage header row
    $Min = 20
    $Max = 20
} else {
    $Min = 1 # Discard Header Row
    $Max = $rawData.Count - 1
}
$rawData[($Min)..($Max)] | Out-File -FilePath ./temp.csv -Force
$csvObj = Import-Csv -Header $Headers -Path ./temp.csv 

##
## TODO Convert to UnitTest
## 
#Write-output ($csvObj)
#foreach($Row in $csvObj) {
#    Write-Output($Row."L")
#}
#exit

## Read JSON cross ref file into a HashTable
$ColHash = (Get-Content -Path ./POContainerXref.json | ConvertFrom-JSON -AsHashtable)

##
## TODO Convert to UnitTest
## 
#Write-output ($ColHash.L)

<##
  Get the table geometry from the data target
#>
## Open Data Source
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
$SqlConnection.open()

## Read Schema from Data Source
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand -Property @{
    Connection = $SqlConnection;
    CommandText = @"
        SELECT c.name, c.is_identity, st.name,  c.max_length, c.precision, c.scale, c.is_nullable
        FROM [$DatabaseName].[sys].[tables] t, [$DatabaseName].[sys].[columns] c, [$DatabaseName].[sys].[systypes] st
        WHERE t.name = '$TableName'
          AND c.object_id = t.object_id
          AND st.xusertype = c.system_type_id
"@
}
$ColumnReader = $SqlCmd.ExecuteReader()
while ($ColumnReader.Read()) {
    $TableMap[$ColumnReader[0]]=@{IsIdentity=$ColumnReader[1];
        Type=$ColumnReader[2];
        Length=$ColumnReader[3];
        Precision=$ColumnReader[4];
        Scale=$ColumnReader[5];
        IsNullable=$ColumnReader[6]
      }
}

exit

## Create-In Memory Table to hold the extracted data from the Modified csv

#$InsertList = New-Object System.Data.DataTable("mem_insertList")

## New Apprach




## Clean up
Remove-Item ./temp.csv
$SqlConnection.close()
<## Frags

        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList "Data Source=SQL12B\SQL2; Integrated Security=True; Initial Catalog=SalesForce"
        $SqlConnection.open()
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand -Property @{
            Connection = $SqlConnection
        }
 $SqlString = @"
 "@

     $typesList = New-Object System.Data.DataTable("mem_ownershipList")
    $typesList.Columns.Add( (New-Object System.Data.DataColumn("type")) )
    foreach ($type in ('Corporate', 'Dealer')) {
      $tmpRow = $typesList.NewRow()
      $tmpRow['type'] = $type
      $typesList.Rows.Add($tmpRow)
    }

#>