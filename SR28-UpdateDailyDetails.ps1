$connectionString = "Provider=Microsoft OLE DB Provider for SQL Server;Data Source=bw8jb2inq1.database.windows.net;Initial Catalog=SR28;Integrated Security=False;User ID=sqladmin;Password=Y0uKn0w3"
$objConn = New-Object System.Data.OleDb.OleDbConnection("$connectionString")
#$sqlCommand = New-Object System.Data.OleDb.OleDbCommand("SELECT * FROM health.DailySummary")
#$sqlCommand.Connection = $objConn
$objConn.open()
#$DataReader = $sqlCommand.ExecuteReader()
#while ($DataReader.read())
#{
    #$DataReader.GetDate(0)
#    $DataReader[0]
#}
#$dataReader.close()
$objConn.close()