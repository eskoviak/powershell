param(
    #The file name
    [Parameter(Mandatory=$true)]
    [String]$ImportFile
)
Import-Module ImportExcel

if (Test-Path ESC:\Documents\Excel) {
    $inputFile = Join-Path ESC:\Documents\Excel -ChildPath $ImportFile
    if (Test-Path $inputFile) {
        $data = Import-Excel -Path $inputFile -WorksheetName Body
        $wrapper = '{ "data" : '
        $wrapper += $data | ConvertTo-Json
        $wrapper += '}'

    } else {
        Write-Error("Input file: {0} not found" -f $inputFile)
        exit -1
    }
} else {
    Write-Error("ESC: not mounted")
    exit -2
}
    