docker run --name sqlserver `
  -p 1433:1433 `
  -e SA_PASSWORD=p@ssw0rd `
  -e ACCEPT_EULA=Y `
  -v C:\Users\edskov\AppData\Roaming\SQLDatabases:/var/opt/mssql/data `
  -d mcr.microsoft.com/mssql/server:2019-latest