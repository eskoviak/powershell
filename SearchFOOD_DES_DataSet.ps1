$strConnection = "Data Source=bw8jb2inq1.database.windows.net;Initial Catalog=SR28;User ID=sqladmin;Password=Y0uKn0w3";
$strQuery = "SELECT RTRIM(NDB_No) AS 'NDB_No', Long_DESC FROM SR28.FOOD_DES WHERE CONTAINS (Long_Desc, 'olives');";
$objConn = New-Object System.Data.SQLClient.SqlConnection($strConnection);
#$sqlCommand = New-Object System.Data.SQLClient.SqlCommand($strQuery);
#$sqlCommand.Connection = $objConn;

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($strQuery, $objConn);
#$adapter.TableMappings.Add("Results", "FOOD_DES");

$objConn.open();

$dataSet = New-Object System.Data.DataSet("FOOD_DES");

$adapter.Fill($dataSet);

$dataSet.GetXml();

#$numRows = $sqlCommand.ExecuteQuery();
#$numRows;
#$DataReader = $sqlCommand.ExecuteReader();
#while ($DataReader.read())
#{
#    $DataReader.GetString(0);
#    $DataReader.GetString(1);
#}
  
#$dataReader.close();
$objConn.close();