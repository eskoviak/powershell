param(
    # The input file name
    [Parameter()]
    [string]
    $filename = './ERPAPPx_Traces.xlsx',

    # The worksheet(s)
    [Parameter()]
    [string[]]
    $worksheets = ('ERPAPP', 'ERP-APP1')
)

Function Compare-ObjectProperties {
    Param(
        # The Reference Object
        [Parameter(Mandatory=$true, Position=0)]
        [PSObject]$ReferenceObject,

        # The Difference Object
        [Parameter(Mandatory=$true, Position=1)]
        [PSObject]$DifferenceObject,

        # If present/set, return only a boolean indicating object equality
        [Parameter()]
        [switch]
        $TestEqual=$false,

        # Array of Properties to compare.  Default (if omtitted) is all
        [Parameter()]
        [string[]]
        $Objprops = @()
    )
    
    if( $Objprops.count -eq 0 ) {
        $Objprops = $ReferenceObject | Get-Member -MemberType Property,NoteProperty | % Name
        $Objprops += $DifferenceObject | Get-Member -MemberType Property,NoteProperty | % Name
        $Objprops = $objprops | Sort | Select -Unique
    }
    $diffs = @()
    foreach ($objprop in $Objprops) {
        $diff = Compare-Object $ReferenceObject $DifferenceObject -Property $objprop
        if ($diff) {
            if($TestEqual) { return $false }            
            $diffprops = @{
                PropertyName=$objprop
                RefValue=($diff | ? {$_.SideIndicator -eq '<='} | % $($objprop))
                DiffValue=($diff | ? {$_.SideIndicator -eq '=>'} | % $($objprop))
            }
            $diffs += New-Object PSObject -Property $diffprops
        }        
    }
    if ($diffs) {
        return ($diffs | Select PropertyName,RefValue,DiffValue)
    } else {
        if($TestEqual) { return $True }
    }     
}

function contains {
    param (
        # input array
        [Parameter(mandatory=$true)]
        [object]
        $Container,

        # element to be tested
        [Parameter(mandatory=$true)]
        [object] 
        $Element
    )

    foreach($object in $Container) {
        if( Compare-ObjectProperties $object $Element -TestEqual) { return $true }
    }
    return $false
}


## Process the nodes
$Nodes = @()
$NodeObj = [PSCustomObject]@{
    _id = ''
    Name = ''
    Type = 'Host'
}

## Get a connection to the local Mongo

for ($i = 0; $i -lt $worksheets.count; $i++) {
    foreach ($item in (import-excel -path $filename -worksheet $worksheets[$i])) {
        if( -not(($item.HostName -match "^[a-zA-Z]{7}-") -or ( $item.HostName -match "-HP|-T44"))) {
            $NodeObj.Name = $item.HostName
            $NodeObj._id = New-Guid
<#             if ( -not $(Contains -Container $Nodes -Element $NodeObj )) {
                $Nodes += $NodeObj.psobject.Copy()
            } #>

        }
    }
}
#write-output($Nodes) | ConvertTo-JSON | Set-Content -path ./nodes.json -encoding utf8
