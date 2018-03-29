# File mapQATomcat.ps1
# 
# maps Tomcat A (d drive) to H:
#      Tomcat B (d drive) to I:

#net use H: \\ap-tcsaoag-qa\d-drive /persistent:no
#net use I: \\ap-tcsoabg-qa\d-drive /persistent:no

$np = "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-PSDrive -Name "qa-a" -PSProvider FileSystem -Root "\\ap-tcsoaag-qa\d-drive"
New-PSDrive -Name "qa-b" -PSProvider FileSystem -Root "\\ap-tcsoabg-qa\d-drive"


