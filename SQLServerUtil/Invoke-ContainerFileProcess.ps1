<##
.synopsis
  Reads the input file from Business area, flters/reformats and does an upsert to the database

.description
  The input file is a bit messy--the header row is nonesense.   A generic header is added, using
  A, B, ..., similar to the Excel default column headings.

.parameter Environment Speciiies the enviroment section in the Configuration.json file to get the
                         environment specific settings

.parameter IsDebu  A switch to indicate local files should be used  (./data)

.example
  PS> Invoke-ContainerFilePreprocess -Envronment development-rws

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

function Get-FileIntoObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $FileName
    )

    $POContainerXref = Get-Content .\POContainerXref.json | ConvertFrom-Json -AsHashtable
    $rawData = Get-Content -Path $FileName

    ## Strip Header row and add a contrived (but useful) header
    $rawData[1..$rawData.Count] | Out-File -FilePath ./temp.csv -Force
    $rawCSVObj = Import-Csv -Path ./temp.csv -Header 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V'
    Remove-Item -Path ./temp.csv

    <##
        Process the raw data appling some filtering:
        -- Remove empty Columns (not values in PRContainerXref)
        -- Map data from arbitrary column headings to Target database column names (POContainerXref Keys)
        -- Remove row where H (PurchaseOrderNum) or J (ItemNum) are emptry
    #>
    $processedList = @()
    foreach ($irow in $rawCSVObj) {
        if (($irow.J.length -eq 0) -or ($irow.H.length -eq 0) ) { continue }
        $propHash = @{}
        foreach ($col in $POContainerXref.Keys) {
            $propHash[$col] = $irow.($POContainerXref.$col)
        }
        $processedList += $propHash
    }

    return $processedList
}

function Set-TableObject {
    [CmdletBinding()]
    param (
        # Dependancy
        [Parameter(mandatory=$true)]
        [PSObject]
        $Configuration
    )

    <## Ed'd Dependancy Injection #>
    $DatabaseName = $Configuration.Environments.$Environment.databaseName
    $ConnectionString = $Configuration.Environments.$Environment.connectionString
    $TableName = $Configuration.Environments.$Environment.tableName
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
    $SqlConnection.open()
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand -Property @{
        Connection = $SqlConnection;
        CommandText = @"
            SELECT c.name, c.is_identity, c.system_type_id, c.max_length, c.precision, c.scale, c.is_nullable
            FROM [$DatabaseName].[sys].[tables] t, [$DatabaseName].[sys].[columns] c
            WHERE t.name = '$TableName'
              AND c.object_id = t.object_id
"@
    }
    $ColumnReader = $SqlCmd.ExecuteReader()
    if ($ColumnReader.HasRows) {
      while($ColumnReader.Read()) {
            
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
                Write-Information "default detected -- {0}" -f $ColumnReader.GetByte(2) -InformationAction Continue
                $column.DataType = [System.Data]::GetType("System.String")
                break
              }
            }
            $column.AllowDBNull = $ColumnReader.GetBoolean(6)
            $memPurchaseOrderContainer.Columns.Add($column)
        }
    } else {
      Write-Error("No rows found for table $tableName")
    }

    <##
      Free up SQL resources
    #>
    $ColumnReader.Close()
    $SqlConnection.close()
}

function Copy-TableObject {
    param (
        # dependancy
        [Parameter(Mandatory=$true)]
        [PSObject]
        $Configuration
    )

    $ConnectionString = $Configuration.Environments.$Environment.connectionString
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
    $SqlConnection.open()
    $sqlBulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy -ArgumentList $SqlConnection
    $sqlBulkCopy.DestinationTableName = "PurchaseOrderContainer_TEMP_KED"
    Write-Information ("Copying local table to server...") -InformationAction Continue
    $sqlBulkCopy.WriteToServer($memPurchaseOrderContainer)
    Write-Information ("...done") -InformationAction Continue    
}

<##
   if (__name__ == '__main__')
#>

<## Setup -- read configs #>
$Configuration = Get-Content .\appsettings.json | ConvertFrom-Json

$memPurchaseOrderContainer = New-Object -TypeName System.data.DataTable -ArgumentList "memPurchaseOrderContainer"

$Filelist = $null
if ($IsDebug) {
    $Filelist = Get-ChildItem -Path (Join-Path -Path (Split-Path -Path $PSCommandPath) -Childpath ($Configuration.Environments.$Environment.dataPath) ) -Filter *.csv
} else {
    $FileList = Get-ChildItem -Path $Configuration.Environments.$Environment.sourceFolder -Filter *.csv
}

if ($null -eq $Filelist ) { Write-Error "No files found to process -- Exiting..." -ErrorAction Exit -1  }
foreach($file in $Filelist) {
    if ($file -match $Configuration.Common.SourceFileRegex ) {
        Write-Host ("Processing $File")

        <## Build filterd hash table from input CSV File #>
        $ContainerList = Get-FileIntoObject -FileName $file
        if ($ContainerList.length -eq 0) { Write-Host "No data inserted for $file" ; continue }

        <## Build an in-memory replica of PurchaseOrderContainer ... #>
        Set-TableObject -Configuration $Configuration
        if( $null -eq $memPurchaseOrderContainer) {
            Write-Output "Table object is null"
            exit -2
        }

        <## ... add the data from the hash table to the data table #>
        foreach ($container in $ContainerList) {
            $row = $memPurchaseOrderContainer.NewRow()
            foreach ($column in (Get-Content .\POContainerXref.json | ConvertFrom-Json -AsHashtable).Keys) {
                $row[$column] = $container.$column
            }

            <## The following Fieldds are not known at this time.  Set them equal to known defaults #>
            $row["PurchaseOrderContainerID"] = -1
            $row["OriginalAddDate"] = "01-01-1990"
            $row["OriginalAddMachineName"] = $env:COMPUTERNAME
            $row["OriginalAddUsername"] = $env:USERNAME

            $memPurchaseOrderContainer.Rows.Add($row)
        }

        $rows = $memPurchaseOrderContainer.Select()
        Write-Information ("Rows inserted: {0}" -f $rows.length) -InformationAction Continue
        Copy-TableObject -Configuration $Configuration
    } else { 
        Write-Host ("Skipping $file")
    }
}
Exit 0