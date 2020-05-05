param(
    # Application Name
    [Parameter(Mandatory=$true)]
    [String]
    $AppName
)

# Get the data
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=10.100.6.96;Database=ED;User id=Ed;Password=1938Ford"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = ("sp_GetApplicationTree N'{0}'" -f $AppName)
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$SqlConnection.Close()


Write-Output $DataSet.Tables[0] | Format-Table