<#

#>
[CmdletBinding()]
param (
)

$imageFileTypes = (
    '*.jpeg',
    '*.tiff',
    '*.tif',
    '*.png',
    '*.nef',
    '*.orf',
    '*.jpg',
    '*.svg'
)

$fileLocations = (
    'D:\Users\edskov\OneDrive - ESC\Pictures',
    'D:\Users\edskov\OneDrive\Pictures'
)

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=localhost;Database=mytest;User id=sa;Password=Thagn0th%"

<## set up the commands#>
#Insert Stored Proc
$SqlInsertCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlInsertCmd.Connection = $SqlConnection
$SqlInsertCmd.CommandType = [System.Data.CommandType]::StoredProcedure
$SqlInsertCmd.CommandText = 'sp_InsertFileInventoryItem'
$p1 = $SqlInsertCmd.Parameters.Add("@FileName", [System.Data.SqlDbType]::VarChar)
$p2 = $SqlInsertCmd.Parameters.Add("@Drive", [System.Data.SqlDbType]::VarChar)
$p3 = $SqlInsertCmd.Parameters.Add("@Path", [System.Data.SqlDbType]::VarChar)
$p4 = $SqlInsertCmd.Parameters.Add("@Length", [System.Data.SqlDbType]::BigInt)
$p5 = $SqlInsertCmd.Parameters.Add("@CreationTime", [System.Data.SqlDbType]::DateTime)


foreach ($fileType in $imageFileTypes) {
    $fileList = Get-ChildItem -Path $fileLocations -Include $imageFileTypes -Recurse
    $SqlConnection.Open()
    foreach ($file in $fileList) {
        $p1.Value = $file.PSChildName
        $p2.Value = $file.PSDrive.ToString()
        $p3.Value = $file.PSPath
        $p4.Value = $file.Length
        $p5.Value = $file.CreationTime
        $result = $SqlInsertCmd.ExecuteNonQuery()
        #Write ('For {0}: Result: {1}' -f $file.PSChildName, $result)
    }
    $SqlConnection.close()
} 

$SqlInsertCmd.Dispose()
