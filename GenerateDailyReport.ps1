sqlcmd -S $ENV:SQLSERVER -d SR28 -U sqladmin -P $ENV:SQLPASSWD -i $ENV:SQLPATH/Health.GenerateDailyReport.sql