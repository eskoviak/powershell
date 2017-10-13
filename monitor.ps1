<#
  This list Paths and Jobs with CPU > a threshold value
#>

$threshold = 10.0

get-process | select-object ID,CPU,ProcessName | % { if($_.ProcessName.equals("WmiPrvSE") -and $_.CPU -gt $threshold) { $_ }}