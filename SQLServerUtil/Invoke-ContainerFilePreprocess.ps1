<##
.synopsis
  Reads the input file from Business area, reformats and writes to a preprocessed file

.description
  The input file is a bit messy--the header row is nonesense.   A generic header is added, using
  A, B, ..., similar to the Excel default column headings.

.parameter Environment Speciiies the enviroment section in the appsettings.json file to get the
                         environment specific settings

.parameter IsDebu  A switch to indicate local files should be used  (./data)

.example
  PS> Invoke-ContainerFilePreprocess -Envronment development-rws

#>

param (
    [CmdletBinding()]

    # Environment 
    [Parameter(Mandatory=$true)]
    [string]
    $Environment,

    # Debug
    [Parameter(Mandatory=$false)]
    [switch]
    $IsDebug

)

<##
  Setup -- read config
#>
$AppSettings = Get-Content .\appsettings.json | ConvertFrom-Json
$SourceFileRegex = $AppSettings.Common.SourceFileRegex
$SourceFolder = $AppSettings.Environments.$Environment.sourceFolder
# This form gets the current working directory fully expanded (no drive names)
#$PSCommandName = Split-Path -Path $PSCommandPath -Leaf

<##
   Get the list of files to process
#>
$Filelist = $null
if ($IsDebug) {
    $Filelist = Get-ChildItem -Path (Join-Path -Path (Split-Path -Path $PSCommandPath) -Childpath ($AppSettings.Environments.$Environment.dataPath) ) -Filter *.csv
} else {
    $FileList = Get-ChildItem -Path $SourceFolder -Filter *.csv
}

if ($null -eq $Filelist ) {
    Write-Host ("No files to process -- Exiting...")
    Exit -1
}

foreach($file in $Filelist) {
    if ($file -match $SourceFileRegex ) {
        Write-Host ("Processing $File")
        $rawData = Get-Content -Path $file
        if($IsDebug) {
            # Just a sample to test with; eliminates the garbage header row
            $Min = 20
            $Max = 40
        } else {
            $Min = 1 # Discard Header Row
            $Max = $rawData.Count - 1
        }
        $rawData[($Min)..($Max)] | Out-File -FilePath ./temp.csv -Force
        $csvObj = Import-Csv -Path ./temp.csv -Header 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V'
        Remove-Item -Path ./temp.csv
        $outfile =(Join-Path -Path (Split-Path $file) -Childpath ('RWISR_'+(Get-Date -Format "yyyyMMddHHmmss")+'_PreProcessed.csv'))
        Write-Host ("Writing File: $outfile")
        $csvObj | Export-Csv -Path $outfile
    } else {
        Write-Host ("Skipping $file")
    }
}
Exit 0