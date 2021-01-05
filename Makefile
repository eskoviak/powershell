CWD = "C:\Users\edskov\repos\powershell"
PSSCRIPT = "C:\Users\edskov\Documents\PowerShell\Scripts"
PS = "pwsh -Command"

Get-ADComputers : 
	$(PS) Copy-Item $(CWD)\Get-ADComputers.ps1 -Destination $(PSSCRIPT)\Get-ADComputers.ps1