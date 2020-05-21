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
    #>
    $processedList = @()
    foreach ($irow in $rawCSVObj) {
        # Apply filters
        if (($irow.H.length -eq 0) -or ($irow.J.length -eq 0) -or ($irow.N.length -eq 0) -or ($irow.O.length -eq 0) ) {
           # Write-Output ("found missing data {0}" -f ($recordCount))
            continue
        }
        if (($irow.H -match '.*[,].*') -or ($irow.J -match '.*[,].*') ) {
            #Write-Output ("found illegal character: {0}" -f $irow)
            continue
        }
        if ( -not ($irow.J -match  '^\d{5}[A-Z]')) {
            #Write-Output ("found bad ItemNum: {0}" -f $irow.J)
            continue
        }

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
    $SqlCmd = new-Object System.Data.SqlClient.SqlCommand -Property @{
        Connection=$SqlConnection;
        CommandText='DELETE FROM wrkPurchaseOrderContainer WHERE 1=1'
    }
    $SqlCmd.ExecuteNonQuery() | Out-Null
    $sqlBulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy -ArgumentList $SqlConnection
    $sqlBulkCopy.DestinationTableName = "wrkPurchaseOrderContainer"
    Write-Information ("Copying local table to server...") -InformationAction Continue
    $sqlBulkCopy.WriteToServer($memPurchaseOrderContainer)
    Write-Information ("...done") -InformationAction Continue
    $SqlConnection.Close()    
}

function Invoke-CommandScript {
    param (
        [Parameter(Mandatory=$true)]
        # The injected configuration
        [psobject]
        $Configuration
    )

    $SqlCommandText = Get-Content -Path C:\Source\Repos\powershell\SQLServerUtil\queries\DatabaseLoader.sql
    $ConnectionString = $Configuration.Environments.$Environment.connectionString
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
    $SqlConnection.open()
    $SqlCmd = new-Object System.Data.SqlClient.SqlCommand -Property @{
        Connection=$SqlConnection;
        CommandType=[System.Data.CommandType]::StoredProcedure;
        CommandText='[dbo].[POCStage]'
    }
    Write-Information("Starting proc POCStage") -InformationAction Continue
    $recsArchived = $SqlCmd.ExecuteScalar()
    Write-Information ("Rows archived: {0}" -f $recsArchived) -InformationAction Continue
    Write-Information("Starting proc POCProcess") -InformationAction Continue
    $SqlCmd.CommandText = '[dbo].[POCProcess]'
    $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()
}
<##
   if (__name__ == '__main__')
#>

<## Setup -- read configs #>
$Configuration = Get-Content .\appsettings.json | ConvertFrom-Json

$memPurchaseOrderContainer = New-Object -TypeName System.data.DataTable -ArgumentList "memPurchaseOrderContainer"
Set-TableObject -Configuration $Configuration
if( $null -eq $memPurchaseOrderContainer) {
    Write-Error "Table object is null" -ErrorAction Exit -2
}


$Filelist = $null
if ($IsDebug) {
    $Filelist = Get-ChildItem -Path (Join-Path -Path (Split-Path -Path $PSCommandPath) -Childpath ($Configuration.Environments.$Environment.dataPath) ) -Filter *.csv | Sort -Property LastWriteTime
} else {
    $FileList = Get-ChildItem -Path $Configuration.Environments.$Environment.sourceFolder -Filter *.csv | Sort -Property LastWriteTime
}

if ($null -eq $Filelist ) { Write-Error "No files found to process -- Exiting..." -ErrorAction Exit -1  }
foreach($file in $Filelist) {
    if ($file -match $Configuration.Common.SourceFileRegex ) {
        Write-Information ("Processing $File") -InformationAction Continue

        <## Build filterd hash table from input CSV File #>
        $ContainerList = Get-FileIntoObject -FileName $file
        if ($ContainerList.length -eq 0) { 
            Write-Information ("No data inserted for $file -- skipping") -InformationAction Continue
            Continue
        }
        $memPurchaseOrderContainer.Clear()

        <## ... add the data from the hash table to the data table #>
        $rowCount = 2
        foreach ($container in $ContainerList) {
            try {
                $row = $memPurchaseOrderContainer.NewRow()
                foreach ($column in (Get-Content .\POContainerXref.json | ConvertFrom-Json -AsHashtable).Keys) {
                    $row[$column] = $container.$column
                }
                $memPurchaseOrderContainer.Rows.Add($row)
            } catch {
                Write-Information ("An error occurred at input line $rowCount") -InformationAction Continue
                Write-Information ($_.Exception.Message ) -InformationAction Continue
            }
            $rowCount += 1
        }

        $rows = $memPurchaseOrderContainer.Select()
        Write-Information ("Rows inserted: {0}" -f $rows.length) -InformationAction Continue
        Copy-TableObject -Configuration $Configuration
        Invoke-CommandScript -Configuration $Configuration
    } else { 
        Write-Information ("Skipping $file") -InformationAction Continue
    }
}
Exit 0