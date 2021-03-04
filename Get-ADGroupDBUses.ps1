<##
.synopsis
Gets the List of Users in the AD Groups which begin with DB_

#>


<##
Type Definitions
$GroupType = @"
public class DBGroup{
    public string Name {get; set;}
    public string Parent {get; set;}
    public string Members {get; set;}
}
"@
Add-Type -TypeDefinition $GroupType

$Groups = @()
#>

write-output "DB_Group,Group1Name, Group1Group, Group2Name, Group2Group-s" | Out-File "dbgroups.csv" -Force

(Get-ADGroup -Filter { Name -like 'DB_*'} -Properties Members, MemberOf) | Foreach-Object {
    $group = $_.Name
    $_.Members | Foreach-Object {
        $parse = $_.Split(',')
        $sub1Name = $parse[0]
        $sub1Group = $parse[1]
        if ($sub1Name.IndexOf('\') -gt 0) {
            # Top level
            $sub2Name = $null
            $sub2Group = $null
        } else {
            $sub1Group = 'GroupMember'
            $sub2Name = $parse[1]
            $sub2Group = $parse[3] + '-' + $parse[2]
        }
        $sub1Name = $sub1Name.Replace("\ ", [String]::Empty)
        Write-Output ("${group},${sub1Name},${sub1Group},${sub2Name},${sub2Group}") | Out-File "dbgroups.csv" -Append
    }
}



<#
$SecurityGroups | Foreach-Object {
    $group = New-Object DBGroup
    $group.Name = $_.Name
    $group.Parent = $_.MemberOf
    $group.Members = $_.Members

    $Groups += $group
}
#>

#ConvertTo-Csv $Groups | out-file groups.csv
#$Groups