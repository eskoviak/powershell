docker run --name mysqldb `
  -e MYSQL_ROOT_PASSWORD=thagn0th `
  -e MYSQL_DATABASE=working `
  -d mysql:latest