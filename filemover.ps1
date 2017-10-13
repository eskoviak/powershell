# Assumes $degama is already set

$files = @("msvcr120.dll","msvcp140.dll")
$localpath = "C:\Windows\System32\"
$destpath = "c:\Windows\System32\"

foreach ($file in $files) {
  #Write-Host ($localpath + $file)
  Copy-Item -ToSession $degama -Path ($localpath + $file) -Destination ($destpath + $file)

}
