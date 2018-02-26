$saPassword = "Thagn0th%"
$dbName = "HealthFacts"
$dbLocalFiles = "C:\Users\eskov\AppData\Local\Microsoft\Microsoft SQL Server Local DB\Instances\MSSQLLocalDB\"
$attachDB = @(@{'dbName'=$dbName}, @{'dbfiles'=@($(Join-Path -Path $dbLocalFiles -ChildPath (($dbName)+".mdf")),
   $(Join-Path -Path $dbLocalFiles -ChildPath (($dbName)+".ldf")))})

#docker run -d -p 1433:1433 -e sa_password=$saPassword -e ACCEPT_EULA=Y -e attach_dbs=$attachDB microsoft/mssql-server-windows-developer
docker run -d -p 1433:1433 -e sa_password=$saPassword -e ACCEPT_EULA=Y  microsoft/mssql-server-windows-developer
