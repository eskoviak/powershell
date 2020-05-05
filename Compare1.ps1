

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
        $TestEqual=$false
    )
    $objprops = @()
    $objprops = $ReferenceObject | Get-Member -MemberType Property,NoteProperty | % Name
    $objprops += $DifferenceObject | Get-Member -MemberType Property,NoteProperty | % Name
    $objprops = $objprops | Sort | Select -Unique
    #Write-Host($objprops)
    $diffs = @()
    foreach ($objprop in $objprops) {
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
    #Write-Host('Objects are equal: {0}' -f $equal )
    if ($diffs) {
        return ($diffs | Select PropertyName,RefValue,DiffValue)
    } else {
        if($TestEqual) { return $True }
    }     
}

$ref = [PSCustomObject]@{
    HostName = "EPAPP"
    Type = "Host"
}

$diff = [PSCustomObject]@{
    HostName  = "ERPAPP"
    Type = "Host"
}

Compare-ObjectProperties $ref $diff