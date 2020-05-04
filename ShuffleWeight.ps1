get-content ..\"ARS Data Base"\weight.dat |
foreach-object {
    $words = -split $_;
    $newOrder = $words[3]+"`t"+$words[1]+"`t"+$words[2]+"`t"+$words[4]+"`t"+$words[5];
    $newOrder >> ..\"ARS Data Base"\weight1.dat
}