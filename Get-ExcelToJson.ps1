Import-Module ImportExcel

$Filename = './ERPAPPx_Traces.xlsx'
$Worksheets = ('ERPAPP', 'ERP-APP1')
$data = @()
$datum = [PSCustomObject]@{
    ServerName = ''
    DBName = ''
    ApplicationName = ''
    ApplicationUser = ''
    UserHost = ''
}

for ($i = 0; $i -lt $worksheets.count; $i++) {
    foreach ($item in (import-excel -path $filename -worksheet $worksheets[$i])) {
        $datum.ServerName = $item.'Server Name'
        $datum.DBName = $item.'ServerDBName'
        $datum.ApplicationName = $item.ApplicationName
        $datum.ApplicationUser = $item.LoginName
        $datum.UserHost = $item.HostName
        $data += $datum.psobject.copy()
    }
}

Write-Output( $data) | ConvertTo-Json | Set-Content -path ../javascript_playgroud/nodes.json
