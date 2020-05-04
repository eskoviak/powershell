$today = get-date -UFormat "%m/%d/%Y";
$today
sqlcmd -d SR28 -S $ENV:SQLSERVER -U sqladmin -P $ENV:SQLPASSWD -Q "EXEC Health.sp_daily_report `'$today`';" > test.txt