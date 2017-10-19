###### Create new session

if ( ${$degama | Select-object State} -eq "Broken") {
    Remove-PSSession $degama
}
$degama = new-pssession -computername 52.38.240.162 -credential ~\eskoviak
