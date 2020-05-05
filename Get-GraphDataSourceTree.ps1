param(
    # Application Name
    [Parameter(Mandatory=$true)]
    [String]
    $DSName
)

# Get the data
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=10.100.6.96;Database=ED;User id=Ed;Password=1938Ford"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = ("sp_GetDataSourceTree N'{0}'" -f $DSName)
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) | Out-Null
$SqlConnection.Close()


Write-Output $DataSet.Tables[0] | Format-Table