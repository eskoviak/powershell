<#
  Get-FileLock -- determines if the file specified is locked by another process
#>
param(
    [Parameter(Mandatory=$true)]
    [String]$FileName
)

if ((Test-Path $FileName) -eq $false) { return $false}

$dummyFile = New-Object System.IO.FileInfo($FileName)

try {
    $dummyStream = $dummyFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, 
      [System.IO.FileShare]::None)
    $dummyStream.close()
    return $false
} catch {
    return $true
}