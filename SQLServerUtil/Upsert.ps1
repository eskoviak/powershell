<#
.Synopsis
  Upsert -- Reads an input file (which has been pre-processed) and inserts or updates a database table

.Description
  

.Example
#>
param (
    [CmdletBinding()]

    # Environment 
    [Parameter(Mandatory=$true)]
    [string]
    $Environment,

    # Debug
    [Parameter(Mandatory=$false)]
    [switch]
    $IsDebug

)

<#
function Get-ColumnName {
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String]
    $ColumnOrdinal,

    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [System.Collections.Hashtable]
    $ColumnHash
  )

  if( $ColumnHash.ContainsValue($ColumnOrdinal)) {
    foreach ($key in $ColumnHash.Keys) {
      if( $ColumnHash[$key] -eq $ColumnOrdinal) { return $Key }
    }
  }
  return $null 
}
 #>

 <##
  Setup -- read config
#>
$AppSettings = Get-Content .\appsettings.json | ConvertFrom-Json
#$POContainerXref = Get-Content .\POContainerXref.json | ConvertFrom-Json -AsHashtable
#Write-Output(Get-ColumnName -ColumnOrdinal M -ColumnHash $POContainerXref)
#exit

$DatabaseName = $AppSettings.Environments.$Environment.databaseName
$ConnectionString = $AppSettings.Environments.$Environment.connectionString
$TableName = $AppSettings.Environments.$Environment.tableName
#$TableMap = @{}
$memDataTable = New-Object System.Data.DataTable -ArgumentList "mPurchaseOrderContainer"

<##
  Query table metadata create an in-memory table to hold data for upsert
#>
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
$SqlConnection.open()
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand -Property @{
    Connection = $SqlConnection;
    CommandText = @"
        SELECT c.name, c.is_identity, c.system_type_id, c.max_length, c.precision, c.scale, c.is_nullable
        FROM [$DatabaseName].[sys].[tables] t, [$DatabaseName].[sys].[columns] c--, [$DatabaseName].[sys].[systypes] st
        WHERE t.name = '$TableName'
          AND c.object_id = t.object_id
          --AND st.xusertype = c.system_type_id
"@
}
$ColumnReader = $SqlCmd.ExecuteReader()
if ($ColumnReader.HasRows) {
  while($ColumnReader.Read()) {
        # skip if identtity
        #if( $ColumnReader.GetBoolean(1) ) { Write-Output ("Identity column -- skipping") ; continue } 
        
        <##
          IF the column is in the xref hash map, get the metadata and create a column in the 
          memory table
        #>
        $column = New-Object System.Data.DataColumn
        $column.ColumnName = $ColumnReader.GetString(0)

        <##
          Convert the native column types to .Net types
        #>
        switch ($ColumnReader.GetByte(2)) {
          56 { $column.DataType =  [System.Type]::GetType("System.Int32"); break }
          58 { $column.DataType = [System.Type]::GetType("System.DateTime"); break }
          {167 -or 168} { $column.DataType = [System.Type]::GetType("System.String"); break}
          Default { 
            Write-Output ("default detected -- {0}" -f $ColumnReader.GetByte(2))
            $column.DataType = [System.Data]::GetType("System.String")
            break
          }
        }
        $column.AllowDBNull = $ColumnReader.GetBoolean(6)
        $memDataTable.Columns.Add($column)
    }
    Write-Output("-- $memDataTable")
  } else {
  Write-Error("No rows found for table $tableName")
}
<##
  Free up SQL resources
#>
$ColumnReader.Close()
$SqlConnection.close()


<##
  Loop through the spreadsheet and populate the table we just built
#>
#$ColumnsOI = $POContainerXref.Values  ## Columns of interest
#$inputData = Import-Csv -Path .\data\RWISR_20200505135338_PreProcessed.csv
#foreach($irow in $inputData) {  ## for each row of the csv file
#  $row = $memDataTable.NewRow()
#  foreach( $col in $ColumnsOI) {
#    $row[(Get-ColumnName -ColumnOrdinal $col -ColumnHash $POContainerXref)] = $irow.$col  ## the magik
#  }
#  $memDataTable.Rows.Add($row)   
#}
#$rows = $memDataTable.Select()
#Write-Output($rows.Length)
