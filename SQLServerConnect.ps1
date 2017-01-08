$strConnection = "Data Source=bw8jb2inq1.database.windows.net;Initial Catalog=SR28;User ID=sqladmin;Password=Y0uKn0w3";
$strQuery = "SELECT * FROM Health.Weight";
$objConn = New-Object System.Data.SQLClient.SqlConnection($strConnection);
$sqlCommand = New-Object System.Data.SQLClient.SqlCommand($strQuery);
$sqlCommand.Connection = $objConn;
$objConn.open();
$DataReader = $sqlCommand.ExecuteReader();
Write-Host "Date`tClient ID`tData Src`tWeight (lb)`tBody Fat (%)";
while ($DataReader.read())
{
    $DataReader.GetDateTime(0);
    $DataReader.GetGUID(1);
}
  
$dataReader.close();
$objConn.close();