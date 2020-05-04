./startSession.ps1
cd c:\users\eskoviak\'Google Drive'\'Shared Proejcts'\'ARS Data Base'
sqlcmd -S bw8jb2inq1.database.windows.net -U sqladmin -d SR28 -P $ENV:SQLPASSWD