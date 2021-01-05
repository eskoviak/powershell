<## 
    .synopsis
        Accepts input from command line as a -like argument for Get-ADComputer


#>

param(
    # $SearchPhrase the search phrase for the computer name
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $SearchPhrase,
	
	# $Interactive force into interactive mode (acccepts input, outputs device name)
	[Parameter(Mandatory=$false)]
	[Switch]$Interactive
)



if($SearchPhrase -ne [String]::Empty) {
	Get-ADComputer -Filter {Name -like $SearchPhrase} -Properties Whencreated, Whenchanged, OperatingSystem, OperatingSystemVersion
} elseif ($Interactive) {
	$response = [String]::Empty
	While ($response -eq [String]::Empty) {
		$SearchPhrase = Read-Host "Enter the search phrase (^C to exit)"
		if (-not ($SearchPhrase -match '^\*.+\*$')) {
			$SearchPhrase = '*' + $SearchPhrase + '*'
		}
		$device = Get-ADComputer -Filter {Name -like $SearchPhrase} -Properties Whencreated
		write-output $device.count
		if ($device.Count -gt 1) {
			Write-Output $device | Select Name, Whencreated | Format-Table
		} else {
			Write-Output ( "Device Name: {0} Created Date: {1}" -f $device.Name, $device.Whencreated)
		}
	}
}