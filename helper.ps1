<##
$string = "CN=Ed Skoviak,OU=Corporate,OU=RWSCUsers,DC=rwsc,DC=net"

$OUs = @()
$frags = $string.split(',')

foreach($frag in $frags){
  $tmp = $frag.split('=')
  if ($tmp[0] -eq 'OU') { $OUs += $tmp[1] }
}

foreach($OU in $OUs) {
  Write-Output($OU)
} 

""

$absoluteStatus = @"
FOUND

Strt:20201119162253

RSLT:FOUND

FLE:C:\BOOTSECT.BAK.hard2decrypt

FN:20201119162253

RT:0
"@
$eol = @("`r", "`r`n")
$t = ($absoluteStatus.Split($eol, [System.StringSplitOptions]::RemoveEmptyEntries))

write-output($t.Length)
#$searchPhrase = 'drebell'
#>
$absoluteFile = '.\absoluteList.xlsx'

if (Test-Path( $absoluteFile )) {
  $absoluteData = Import-Excel -Path $absoluteFile -Worksheet Sheet1

  #$absoluteData | Sort-Object -Property Model -Unique | Select-Object -Property Model
  $tmp = ($absoluteData[1].FileDectectResultDiagnostics)
  $Status = $tmp.Substring(0, $tmp.IndexOf(':')-6)
  $StatusDt = $tmp.Substring($tmp.IndexOf(':')+1, 8)
  $Status
  $StatusDt
}
  

