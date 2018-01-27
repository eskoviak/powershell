param(
    [CmdletBinding()]

    # The input file
    [Parameter()]
    [String]
    $Datafile = 'ESC:\Documents\Excel\Harvard Calories Burned.xlsx',

    # The Activity to search for
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]
    $Activity
)
Import-Module ImportExcel

if (-not (Test-Path $Datafile)) {
    Write-Error $("Datafile {0} not found" -f $Datafile )
} else {
    $Activity = "*"+$Activity+"*"
    $dataObj = Import-Excel -Path $Datafile -WorksheetName Calories
<#     ForEach-Object -InputObject $dataObj -Process {
        if ($row.Activity -like $Activity ) {
        }
    } #>
    foreach ($row in $dataObj) {
        if ($row.Activity -like $Activity) {
            Write-Output ("{0}`t{1}`t{2}`t{3}" -f $row.Activity, $row.125, $row.155, $row.185)
        }
     }
}