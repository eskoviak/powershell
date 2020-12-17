Import-Module ImportExcel

<## USER TYPES #>
$UserRecordSource = @"
public class UserRecord {
    public string DistinguishedName { get; set; }
    public string Name { 
        get {
            string[] frags=this.DistinguishedName.Split(',');
            foreach (string frag in frags) {
                string[] hash = frag.Split('=');
                if(hash[0].Equals("CN")) return hash[1];
            }
            return "";
        }    
    }
    public string GivenName { get; set; }
    public string Surname { get; set; }
    public string Location {
        get {
            string[] frags=this.DistinguishedName.Split(',');
            foreach (string frag in frags) {
                string[] hash = frag.Split('=');
                if( hash[0].Equals("OU") && !( hash[0].Equals("RWSUsers") || hash[0].Equals("Sales") ) ) return hash[1];
            }
            return "";
        } 
    }
    public string Description { get; set; }
    public string Office { get; set; }
    public string UserSamAccount{ get; set; }
    public string ComputerSamAccount { get; set; }
	public string ComputerSamAccountCreateDt { get; set; }
    public string AbsoluteStatus { get; set; }
    public string AbsoluteStatusDt { get; set; }
    public string DeviceType { get; set; }
}
"@
Add-Type -TypeDefinition $UserRecordSource


$ComputerRecordSource = @"
public class ComputerRecord {
	public string DistinguishedName { get; set; }
    public string Name { get; set; }
    public string WhenCreated { get; set; }
}
"@
Add-Type -TypeDefinition $ComputerRecordSource
<## END USER TYPES #>

$SubOUExcludes = @('Retail')
$AbsoluteFileName = '.\absoluteList.xlsx'

function ExcludeOU {
    param(
        # OU to Test for
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $OU
    )

    $SubOUExcludes | ForEach-Object {
        if ($_ -eq $OU) { return $true }
    }
    return $false
}

function GetComputer {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $SamAccountName 
    )
    $ComputerRecords = @()
    $Computers | ForEach-Object{
        if ($_.Name -like $SamAccountName+"*") {
            $ComputerRecord = New-Object -TypeName ComputerRecord
            $ComputerRecord.Name = $_.Name
            $ComputerRecord.WhenCreated = $_.WhenCreated
            $ComputerRecords += $ComputerRecord
         } 
    }
    
    return $ComputerRecords
}

Function Get-AbsoluteData {
    param(
        # Input SamAccountName
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String] $SamAccountName
    )

    $AbsoluteRecord = $null
    $AbsoluteData | ForEach-Object {
        if($_.'Device name' -like $SamAccountName+"*") {
            $AbsoluteRecord = $_ 
        }
    }
    return $AbsoluteRecord
}

Function Add-Users {
	$Users | ForEach-Object {
		$Record = New-Object -TypeName UserRecord
		$Record.DistinguishedName = $_.DistinguishedName
		$Record.GivenName = $_.GivenName
		$Record.Surname = $_.Surname
		$Record.Description = $_.Description
		$Record.Office = $_.Office
		$Record.UserSamAccount = $_.SamAccountName
		#$Record.ComputerSamAccount = GetComputer $_.SamAccountName
		(GetComputer $_.SamAccountName) | ForEach-Object {
			$Record.ComputerSamAccount += $_.Name
			$Record.ComputerSamAccountCreateDt += $_.WhenCreated
		}
		#$AbsoluteRecord = Get-AbsoluteData $_.SamAccountName
		#$Record.AbsoluteStatus = Get-AbsoluteData $_.SamAccountName
		$Records += $Record
	}

	$Count += 1
}
$Records = @()
$Computers = Get-AdComputer -Filter * -Properties WhenCreated -SearchBase "OU=New,OU=Workstations,DC=rwsc,DC=net"
$AbsoluteData = Import-Excel -Path $AbsoluteFileName -WorksheetName 'Sheet1' 

Write-Output ('Processing OU=RWSCUsers,DC=rwsc,DC=net' )
$Users = Get-ADUser -Filter * -Properties Description,Office -SearchBase "OU=RWSCUsers,DC=rwsc,DC=net"
$Count = 0
Add-Users
Write-Output ('Read {0} Records from OU RWSCUsers' -f $Count)

Write-Output('Processing OU=Sales,DC=rwsc,DC=net')
$Users = Get-ADUser -Filter *  -Properties Description -SearchBase "OU=Sales,DC=rwsc,DC=net"
$count = 0
Add-Users
Write-Output ('Read {0} Records from OU Sales' -f $count)

#$Records | Export-Excel
#$Records | ForEach-Object {
#    if(ExcludeOU $_.Location) { continue }
#    else  { Write-Output $_ }
# } | Export-Excel
$Records | Where-Object { -not( $_.Location -Match "Retail" )} | Export-Excel
