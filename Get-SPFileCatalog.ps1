<##
.SYNOPSIS
Given a local (sync) copy of a SP library, builds a catlog


#>
[CmdletBinding()]
param(
    
)
Import-Module ImportExcel

$source = @"
public class FileItem {
    public string FileName;

    public string toString() {
        return FileName;
    }
}
"@
Add-Type -TypeDefinition $source
$Rows = @()


$location = '\SharePoint\Enterprise Architecture Team - Docu'
$cloudDrive = (Join-Path -Path $ENV:USERPROFILE -ChildPath '')
(Get-ChildItem -Path (Join-Path -Path $ENV:USERPROFILE -ChildPath $Location)) | ForEach-Object -Process { 
    $tmp = New-Object FileItem
    $tmp.FileName = $_.Name
    $Rows += $tmp
    }

Export-Excel -Path ./oldSPFileInventory.xlsx -InputObject $Rows -WorksheetName 'Files'
