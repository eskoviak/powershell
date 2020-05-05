$filePaths = ('C:\Users\edskov\SharePoint\Enterprise Architecture Team - Docu', 'C:\Users\edskov\Red Wing Shoe Company')
$cutoffDate = New-Object System.DateTime(2018,11,1)

foreach($path in $filePaths){
    Get-ChildItem -Path $path -Include *.vsd* -Recurse -Attributes !Directory | Where-Object -Property LastWriteTime -CGE $cutoffDate

}