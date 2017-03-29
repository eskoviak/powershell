#$env:KARAF_HOME='C:\IFBIDEV\server\apache-karaf-4.0.7\apache-karaf-4.0.7'
#start ${env:KARAF_HOME}\bin\karaf
$karafStatus = gsv | where-object {$_.DisplayName -eq 'karaf'} | select-object -property Status
if ($karafStatus.Status -eq'Running') {
  $choice = read-host "Karaf is running; do you wish to stop it? [Y|n]"
  if ($choice -eq '' -or $choice -eq 'Y' -or $choice  -eq  'y') {
	net stop karaf
  }
} else {
  $choice = read-host "Karaf is not running; do you wish to start it? [Y|n]"
  if ($choice -eq '' -or $choice -eq 'Y' -or $choice -eq 'y') {
	net start karaf
	}
}