# File mapQATomcat.ps1
# 
# maps Tomcat A (d drive) to H:
#      Tomcat B (d drive) to I:

#net use H: \\ap-tcsaoag-qa\d-drive /persistent:no
#net use I: \\ap-tcsoabg-qa\d-drive /persistent:no

New-PSDrive -Name "H" -PSProvider FileSystem -Persist -Root "\\ap-tcsoaag-qa\d-drive"
New-PSDrive -Name "I" -PSProvider FileSystem -Persist -Root "\\ap-tcsoabg-qa\d-drive"
