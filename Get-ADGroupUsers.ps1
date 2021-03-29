$filename = "DBUsers.txt"
Write-Output "User List for Group Like DB_* Run Date: " + [System.DateTime]::Now | Out-File $filename -Force
Get-ADGroup -Filter {Name -like 'DB_*'} | Foreach-Object {
    Write-Output ("+++`n+ Group $_.Name`n+++") | Out-File $filename -Append
    Get-ADGroupMember $_.Name | Foreach-Object {
        if($_.ObjectClass -eq 'user') {
            Write-Output ("(leaf) " + $_.DistinguishedName) | Out-File $filename -Append
        } elseif ($_.ObjectClass -eq 'group') {
            $tmp = $_.Name
            Get-ADGroupMember $_.Name | Foreach-Object {
                if($_.ObjectClass -eq 'user') {
                    Write-Output ("(${tmp}) " + $_.DistinguishedName) | Out-File $filename -Append
                } elseif ($_.ObjectClass -eq 'group') {
                    $tmp = $tmp + ":"+ $_.Name
                    Get-ADGroupMember $_.Name | Foreach-Object {
                        if($_.ObjectClass -eq 'user') {
                            Write-Output ("(${tmp}) " + $_.DistinguishedName) | Out-File $filename -Append
                        } elseif ($_.ObjectClass -eq 'group') {
                            $tmp = $tmp + ":"+ $_.Name
                            Get-ADGroupMember $_.Name | Foreach-Object {
                                Write-Error "Inner Loop"
                            }
                        } else {
                            Write-Error "Unhandled ObjectClass"
                        }
                    }
                } else {
                    Write-Error "Unhandled ObjectClass"
                }
            }
        } else {
            Write-Error "Unhandled ObjectClass"
        }
    }
    Write-Output "**************************" | Out-File $filename -Append
}
