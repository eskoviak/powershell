Import-Module ActiveDirectory
Import-Module ImportExcel

$datafile = ".\RedEdge SSO Roles to groups V8.xlsx"

$data = ''

if (Test-Path $datafile) {
    $data  = Import-Excel $datafile -WorksheetName 'Roles and Examples'
    $data | ForEach-Object {
        if($_.SamAccountName -ne $null) {
            #(Get-ADUser $_.SamAccountName) | Select-Object DistinguishedName
            $groups = @()
            $mgr = $false
            $SamAccountName = $_.SamAccountName
            (Get-ADUser $_.SamAccountName -Properties MemberOf | Select-Object MemberOf).MemberOf | 
              ForEach-Object {
                if($_ -like '*RedEdge Corp Store Managers*') {
                    $global:mgr = $true
                }
            }
            Write-Host('SAM {0}, Manager {1}' -f $SamAccountName, $global:mgr)
        }
    }
    #Export-Excel -Path $datafile -WorkSheetname 'Roles and Examples' -TargetData $data 
}

