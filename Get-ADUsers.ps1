Import-Module ImportExcel

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
    public string AbsoluteStatus { get; set; }
}
"@
Add-Type -TypeDefinition $UserRecordSource


$ComputerRecordSource = @"
public class ComputerRecord {
    public string Name { get; set; }
    public string WhenChanged { get; set; }
}
"@
Add-Type -TypeDefinition $ComputerRecordSource

$SubOUExcludes = @('Retail')

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
            $ComputerRecord.WhenChanged = $_.Whenchanged
            $ComputerRecords += $ComputerRecord
         } 
    }
    
    return $ComputerRecords
}

$Records = @()
$Users = Get-ADUser -Filter {Enabled -eq $true}  -Properties Description,Office -SearchBase "OU=RWSCUsers,DC=rwsc,DC=net"
$Computers = Get-AdComputer -Filter {Enabled -eq $true} -Properties Whenchanged -SearchBase "OU=New,OU=Workstations,DC=rwsc,DC=net"
 

Write-Output ('Processing OU=RWSCUsers,DC=rwsc,DC=net' )
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
        $Record.ComputerSamAccount += $_.Name + ' (' + $_.WhenChanged + ') '
    }
    $Records += $Record
}

Write-Output ('Read {0} Records from OU RWSCUsers' -f $Records.Length)

Write-Output('Processing OU=Sales,DC=rwsc,DC=net')
$Users = Get-ADUser -Filter {Enabled -eq $true}  -Properties Description -SearchBase "OU=Sales,DC=rwsc,DC=net"
$count = 0

$Users | ForEach-Object {
    $Record = New-Object -TypeName UserRecord
    $Record.DistinguishedName = $_.DistinguishedName
    $Record.GivenName = $_.GivenName
    $Record.Surname = $_.Surname
    $Record.Description = $_.Description
    $Record.Office = $_.Office
    $Record.UserSamAccount = $_.SamAccountName
    (GetComputer $_.SamAccountName) | ForEach-Object {
        $Record.ComputerSamAccount += $_.Name + ' (' + $_.WhenChanged + ') '
    }
    $Records += $Record
    $count += 1
}
Write-Output ('Read {0} Records from OU Sales' -f $count)

#$Records | Export-Excel
#$Records | ForEach-Object {
#    if(ExcludeOU $_.Location) { continue }
#    else  { Write-Output $_ }
# } | Export-Excel
$Records | Where-Object { -not( $_.Location -Match "Retail" )} | Export-Excel
