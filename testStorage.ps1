$content = Get-Content -path ../XML/Hamlet.xml
$outfileBase = 'speedtest'


$start = get-date
for ($count = 1; $count -le 10; $count++) {
	$outfile = '.\'+$outfileBase+$count+'.xml'
	$content | out-file -filepath $outfile
}

$end = get-date

$spanMS = new-timespan $start $end
Write-Host 'Elapsed Time: ' $spanMS.TotalMilliseconds ' ms'