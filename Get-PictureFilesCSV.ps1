<#

#>
[CmdletBinding()]
param (
    # Test flag
    [Parameter(Mandatory=$false)]
    [Switch]
    $IsTest
)

$imageFileTypes = (
    '*.jpeg',
    '*.tiff',
    '*.tif',
    '*.png',
    '*.nef',
    '*.orf',
    '*.jpg',
    '*.svg',
    '*.psd'
)

$fileLocations = (
    'D:\OneDrive - ESC\Pictures'
    #'C:\Users',
    #'D:\'
)

$PicFiles = @()
if( $IsTest ) {
    $FileInfoList = Get-ChildItem -Path img_1783.jpg
} else {
    $FileInfoList = Get-ChildItem -Path $fileLocations -Include $imageFileTypes -Recurse      
}

foreach($FileInfo in $FileInfoList){
    $Info = @{
        Name=$FileInfo.PSChildName
        ParentFolder=$FileInfo.PSPath.split("::")[1]
        Length=$FileInfo.Length
        CreateDate=$FileInfo.CreationTime.ToString()
    }
    $PicFiles += New-Object PSObject -Property $Info
}

if($IsTest){
    Write-Output $PicFiles
} else {
    Write-Output $PicFiles |
        Export-CSV -Path ./images.csv -NoTypeInformation
}       
#         #Export-CSV -Path D:\Data\pictures\pictures.csv -NoTypeInformation
