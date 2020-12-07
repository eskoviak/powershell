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
#>

$searchPhrase = 'drebell'

$absoluteFile = '.\absoluteList.xlsx'

if (Test-Path( $absoluteFile )) {






}

  

