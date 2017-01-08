#    Script InsertDailyDetail.ps1
#    
#    Optionally processes the SR28.InsertDailyDetail TSQL, then
#    generates the report (GetDetailReport.sql)
#    
#    V1.0 01/23/2016  ELS Original   
Param(
    [switch]$runInsert
)

if ($runInsert)
{
    sqlcmd -S bw8jb2inq1.database.windows.net -U sqladmin -d SR28 -i ..\SQL\"SR28.InsertDailyDetailRecord.sql"
} else
{
    Write-Host "Skipping table insert..."
}
sqlcmd -S bw8jb2inq1.database.windows.net -U sqladmin -d SR28 -i ..\SQL\"GetDetailReport.sql"
