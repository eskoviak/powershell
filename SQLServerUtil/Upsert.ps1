<#
.Synopsis
  Upsert -- Reads an input file and inserts or updates a database table

.Description
  

.Example
#>

<## EdWorkstation
$DatabaseName = "Activity"
$TableName = "HarvardActivityReference"
$ConnectionString = "Server=EDWORKSTATION\SQLDEV;database=$DatabaseName;Integrated Security=true"
#>
$DatabaseName = "PurchaseOrderContainer"
$TableName = "PurchaseOrderContainer"
$ConnectionString = "Server=SQL12DEV\SQL2;database=$DatabaseName;Integrated Security=true"

$TableMap = @{}
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
$SqlConnection.open()
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
while($ColumnReader.Read()) {
    $TableMap[$ColumnReader[0]]=@{IsIdentity=$ColumnReader[1];
                                  Type=$ColumnReader[2];
                                  Length=$ColumnReader[3];
                                  Precision=$ColumnReader[4];
                                  Scale=$ColumnReader[5];
                                  IsNullable=$ColumnReader[6]
                                }
}
Write-Output $TableMap
Write-Output $TableMap["ContainerNum"]
Write-Output $TableMap["ContainerNum"]["Type"]
$SqlConnection.close()