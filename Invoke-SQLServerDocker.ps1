$saPassword = "Thagn0th%"
#$dbName = "mytest"
#$dbLocalFiles = "c:/data"
#$attachDB = @({"dbName":($dbName), @{'dbfiles'=@($(Join-Path -Path $dbLocalFiles -ChildPath (($dbName)+".mdf")),
#   $(Join-Path -Path $dbLocalFiles -ChildPath (($dbName)+".ldf")))})

#HP-840
#$attachDB = "[{'dbName' : 'HealthFacts', 'dbFiles' : ['c:\\data\\HealthFacts.mdf', 'c:\\data\\HealthFacts.ldf']}]"
#EdGamer
#$attachDB = "[{'dbName' : 'mytest', 'dbFiles' : ['c:\\data\\mytest.mdf', 'c:\\data\\mytest.ldf']}]"
#docker run -d -p 1433:1433 -e sa_password=$saPassword -e ACCEPT_EULA=Y --mount type=bind,source="D:/SQLDatabases",target="c:/data" -e attach_dbs=$attachDB microsoft/mssql-server-windows-developer
#docker run -d -p 1433:1433 -e sa_password=$saPassword -e ACCEPT_EULA=Y  microsoft/mssql-server-windows-developer
docker run -d -p 1433:1433 -e sa_password=$saPassword -e ACCEPT_EULA=Y --mount type=bind,source="C:/Users/edskov/SQLDatabases",target="c:/data" microsoft/mssql-server-windows-developer
