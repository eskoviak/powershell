$j = Start-Job -Name DoSomething -ScriptBlock {
	Start-Sleep -s 15
	& ping.exe yahoo.com
	Write-output $LASTEXITCODE
}

while ($j.State -ne "Completed") {
	Write-Host "." -NoNewLine
	Start-Sleep -s 1
}

Write-Host "#"
$j | Receive-Job

#Get-Job -Name DoSomething | Wait-Job | Receive-Job