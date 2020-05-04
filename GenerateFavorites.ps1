# Generate Favorites Report
#
cd c:\users\eskoviak\"Google Drive"\"Shared Proejcts"\SQL
sqlcmd -d SR28 -S $ENV:SQLSERVER -U sqladmin -P $ENV:SQLPASSWD -i "Generate Favorites Report.sql" -o "..\Favorites.rpt"
cd c:\users\eskoviak\"Google Drive"\"Shared Proejcts"\PowerShell
