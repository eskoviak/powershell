<#
.Synopsis
  Upsert -- Reads an input file and inserts or updates a database table

.Description
  

.Example
#>
$TableName = "HarvardActivityReference"
$TableMap = @{}
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ArgumentList 'Server=EDWORKSTATION\SQLDEV;database=Activity;Integrated Security=true'
$SqlConnection.open()
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand -Property @{
    Connection = $SqlConnection;
    CommandText = @"
        SELECT c.name, c.is_identity, st.name,  c.max_length, c.precision, c.scale, c.is_nullable
        FROM [Activity].[sys].[tables] t, [Activity].[sys].[columns] c, [Activity].[sys].[systypes] st
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
Write-Output $TableName["Id"]
$SqlConnection.close()