$strFileName = "C:\Users\Ed\OneDrive for Business\Health Journal\Health Journal--New.xlsm"
$strSheetName = 'Detail$'
#$strProvider = "Provider=Microsoft.Jet.OLEDB.4.0"
#$strProvider = "Provider=Microsoft Office 12.0 Access Database Engine OLE DB Provider"
$strProvider="Provider=Microsoft.ACE.OLEDB.15.0"
$strDataSource = "Data Source = $strFileName"
$strExtend = "Extended Properties=Excel 8.0"
$strQuery = "Select Date, Food from [$strSheetName]"
#$strQuery = "SELECT Date, Food, NaCl, Cal, K, Protein, Carb, Fat, Cholesterol "
#$strQuery += "FROM [$strSheetName] "
$strQuery
#$strOutputData = @()
$objConn = New-Object System.Data.OleDb.OleDbConnection("$strProvider;$strDataSource;$strExtend")
$sqlCommand = New-Object System.Data.OleDb.OleDbCommand($strQuery)
$sqlCommand.Connection = $objConn
$objConn.open()
$DataReader = $sqlCommand.ExecuteReader()
#$DataReader.getSchemaTable()
while ($DataReader.read())
{
    #$DataReader.GetDate(0)
    $DataReader[0]
}

#While($DataReader.read())
#{
# $line = $dataReader.getString(0)
# write-host $line  
 #$ComputerName = $DataReader[0].Tostring()
 #$line = $dataReader[0].tostring() + "," 
 #   + $dataReader[3].tostring() + ","
 #   +$dataReader[6] 
 #write-host $line
 #"Querying $computerName ..."
 #Get-WmiObject -Class Win32_Bios -computername $ComputerName
#}  
$dataReader.close()
$objConn.close()